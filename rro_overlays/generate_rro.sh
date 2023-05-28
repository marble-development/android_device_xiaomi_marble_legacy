#!/usr/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEBUG=0
if [[ ${DEBUG} != 0 ]]; then
    log="/dev/tty"
else
    log="/dev/null"
fi

if [[ -z ${1} ]]; then
    echo usage: generate_rro.sh /path/to/rro.apk
    exit
fi

SRC="${1}"

# Create a temporary working directory
TMPDIR=$(mktemp -d)

name=$(basename ${SRC} | sed "s/.apk//g")

if ! apktool d "${SRC}" -o "${TMPDIR}"/out &> "${log}"; then
    echo "Failed to dump ${name}"
    # Clear the temporary working directory
    rm -rf "${TMPDIR}"
    exit
fi

rm -rf mkdir ./rro_overlays/${name}
mkdir ./rro_overlays/${name}

# Copy resources from apktool dump
cp -r ${TMPDIR}/out/res ./rro_overlays/${name}/
rm ./rro_overlays/${name}/res/values/public.xml
# If public.xml was the only file in res/values remove it
if [[ -z "$(ls -A ./rro_overlays/${name}/res/values)" ]]; then
    rm -rf ./rro_overlays/${name}/res/values
fi

# Begin writing Android.bp
printf "runtime_resource_overlay {
    name: \"${name}\"," > ./rro_overlays/${name}/Android.bp

# Set theme if necessary
theme=$(echo $SRC | sed -n "s/.*overlay\/\([a-zA-Z0-9_-]\+\)\/.*\.apk/\1/gp")
echo "theme is: ${theme}" > "${log}"
if [[ ! -z "${theme}" ]]; then
    printf "\n    theme: \"${theme}\"," >> ./rro_overlays/${name}/Android.bp
fi

# Choose the partition
partition=$(echo $SRC | sed -n "s/.*\/\([a-z]\+\)\/overlay.*/\1/gp")
echo "partition is: ${partition}" > "${log}"
if echo "product system_ext" | grep -w -q ${partition}; then
    printf "\n    ${partition}_specific: true," >> ./rro_overlays/${name}/Android.bp
elif echo "vendor" | grep -w -q ${partition}; then
    printf "\n    vendor: true," >> ./rro_overlays/${name}/Android.bp
fi

# Keep raw values if necessary
# Experimental logic: Check if there are values starting with 0 and assume that the leading 0s
# are critical and should be kept
if [[ ! -z $(find ./rro_overlays/${name}/res -type f | xargs -I 'file' sed -n "/\(=\"0[0-9]\+\)/p" file) ]]; then
    printf "\n    aaptflags: [\"--keep-raw-values\"]," >> ./rro_overlays/${name}/Android.bp
fi

# Finish the Android.bp
printf "\n}\n" >> ./rro_overlays/${name}/Android.bp

# Get attributes from AndroidManifest.xml
package=$(sed -n "s/.*package=\"\([a-z.]\+\)\".*/\1/gp" ${TMPDIR}/out/AndroidManifest.xml)
targetPackage=$(sed -n "s/.*targetPackage=\"\([a-z.]\+\)\".*/\1/gp" ${TMPDIR}/out/AndroidManifest.xml)
targetName=$(sed -n "s/.*targetName=\"\([a-zA-Z.]\+\)\".*/\1/gp" ${TMPDIR}/out/AndroidManifest.xml)
isStatic=$(sed -n "s/.*isStatic=\"\([a-z]\+\)\".*/\1/gp" ${TMPDIR}/out/AndroidManifest.xml)
priority=$(sed -n "s/.*priority=\"\([0-9]\+\)\".*/\1/gp" ${TMPDIR}/out/AndroidManifest.xml)

echo "package is: ${package}" > "${log}"
echo "targetPackage is: ${targetPackage}" > "${log}"
echo "targetName is: ${targetName}" > "${log}"
echo "isStatic is: ${isStatic}" > "${log}"
echo "priority is: ${priority}" > "${log}"

# Begin writing AndroidManifest.xml
printf "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"
    package=\"${package}\">
    <overlay android:targetPackage=\"${targetPackage}\"" > ./rro_overlays/${name}/AndroidManifest.xml

# Write optional properties and close the overlay block
optional_properties=""
if [[ ! -z "${targetName}" ]]; then
    optional_properties="${optional_properties}\n                   android:targetName=\"${targetName}\""
fi
if [[ ! -z "${isStatic}" ]]; then
    optional_properties="${optional_properties}\n                   android:isStatic=\"${isStatic}\""
fi
if [[ ! -z "${priority}" ]]; then
    optional_properties="${optional_properties}\n                   android:priority=\"${priority}\""
fi
printf "${optional_properties}/>\n" >> ./rro_overlays/${name}/AndroidManifest.xml

# Close the manifest
printf "</manifest>\n" >> ./rro_overlays/${name}/AndroidManifest.xml

# Clear the temporary working directory
rm -rf "${TMPDIR}"
