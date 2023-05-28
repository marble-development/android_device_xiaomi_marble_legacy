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
    echo usage: beautify_rro.sh /path/to/rro_source [/path/to/original_source]
    exit
fi

ANDROID_ROOT="../../.."

RRO_DIR="${1}"
SRC_DIR=""
targetPackage=$(sed -n "s/.*targetPackage=\"\([a-z.]\+\)\".*/\1/gp" ${RRO_DIR}/AndroidManifest.xml)
if [[ ! -z ${2} ]]; then
    SRC_DIR=${2}
else
    echo "Guessing source for $targetPackage" > ${log}

    case "${targetPackage}" in
    "android")
        SRC_DIR=${ANDROID_ROOT}/frameworks/base/core/res
        ;;
    "com.android.systemui")
        SRC_DIR=${ANDROID_ROOT}/frameworks/base/packages/SystemUI
        ;;
    "com.android.providers.settings")
        SRC_DIR=${ANDROID_ROOT}/frameworks/base/packages/SettingsProvider
        ;;
    *)
        SRC_DIR=$(rg "package=\"${targetPackage}\"" ${ANDROID_ROOT}/packages/ | grep -v install-in-user-type | sed "s/://g" | awk '{print $1}' | sed "s/\(..\/..\/..\/[a-zA-Z0-9]\+\/[a-zA-Z0-9]\+\/[a-zA-Z0-9]\+\).*/\1/g" | head -1)
        ;;
    esac

    echo "Guessed source: $SRC_DIR" > ${log}
fi

if [[ -z ${SRC_DIR} ]] || [[ ! -d ${SRC_DIR} ]]; then
    echo "Could not find source for $targetPackage, last guess: ${SRC_DIR}"
    exit
else
    echo "Using source: $SRC_DIR" > ${log}
fi

# Create a temporary working directory
TMPDIR=$(mktemp -d)

function get_src_path () {
    # Allow space between "name" and "="
    # Ignore symbols.xml and overlayable.xml files since these don't contain the actual values
    # Only print the first occurance

    name_search="$(echo ${name} | sed "s/name=/name[ ]*=/g")"
    src_path=$(grep -rG "${name_search}" ${SRC_DIR} | grep -v symbols.xml | grep -v overlayable.xml | sed "s/://g" | awk '{print $1}' | head -1)
}

function add_aosp_comments () {
    local file=${1}

    # Create a backup
    cp ${file} ${TMPDIR}/$(basename ${file}).bak

    for name in $(grep -r "name=" ${file} | sed "s/translatable=\"false\"/ /g" | sed "s/[<>]/ /g" | sed "s/\"/\\\\\"/g" | awk '{print $2}'); do
        if ! grep -qr ${name} ${SRC_DIR}; then
            echo "[$(basename ${RRO_DIR})] Resource $(echo ${name} | sed "s/.*\"\([a-Z0-9_.]\+\)\\\.*/\1/g") not found in $(echo ${SRC_DIR} | sed "s/$(echo ${ANDROID_ROOT}/ | sed "s/\//\\\\\//g")//g")"
            continue
        fi

        get_src_path
        if [[ ! -f ${src_path} ]]; then
            echo "src_path: $src_path does not exist, skipping" > ${log}
            continue
        fi

        # Is the string translatable?
        if [[ ! -z $(sed -n "/${name_search}/p" ${src_path} | sed -n "/translatable=\"false\"/p") ]] && [[ -z $(sed -n "/${name}/p" ${file} | sed -n "/translatable=\"false\"/p") ]]; then
            sed -i "s/${name_search}/${name} translatable=\"false\"/g" ${file}
        fi

        line=$(sed -n "/.*${name_search}.*/=" ${src_path} | head -1)
        if [[ -z $(sed -n "$(expr ${line} - 1)p" ${src_path} | sed -n "/.*-->.*/p") ]]; then
            echo "Did not find ending string before ${name} in ${src_path}" > ${log}
            continue
        fi

        line=$(sed -n "/.*${name}.*/=" ${file} | head -1)
        if [[ ! -z $(sed -n "$(expr ${line} - 1)p" ${file} | sed -n "/.*-->.*/p") ]]; then
            echo "There is already a comment for ${name} in ${file}, skipping" > ${log}
            continue
        fi

        # Drop everything after our item
        sed "/${name_search}/q" ${src_path} > "${TMPDIR}"/before.txt

        # Search for the last "<!--" before the item and write from there up to the item
        sed -n "$(sed -n /\<\!--/= "${TMPDIR}"/before.txt | tail -1),\$p" "${TMPDIR}"/before.txt | head -n -1  > "${TMPDIR}"/comment.txt

        # Add empty line above comment, skip if this is the first value in this file
        line=$(sed -n "/.*${name}.*/=" ${file} | head -1)
        if [[ ! ${line} -eq $(grep -Pn -m 1 "<[-A-Za-z]+ name=" ${file} | grep -Po "^[0-9]+") ]]; then
            sed -i '1s/^/\n/' "${TMPDIR}"/comment.txt
        fi

        # Insert the comment above the item
        sed -i "$(expr ${line} - 1) r ${TMPDIR}/comment.txt" ${file}
    done

    if ! xmllint --format ${file} &> /dev/null; then
        echo "We broke ${file}. Restoring backup"
        cp ${TMPDIR}/$(basename ${file}).bak ${file}
    fi
    rm ${TMPDIR}/$(basename ${file}).bak
}

function init_file () {
    local name=${1}
    if [[ -f ${folder}/${name} ]]; then
        return
    fi

    printf -- "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" >> ${folder}/${name}
    printf -- "<!--\n" >> ${folder}/${name}
    printf -- "     Copyright (C) $(date +%Y) The LineageOS Project\n" >> ${folder}/${name}
    printf -- "     SPDX-License-Identifier: Apache-2.0\n" >> ${folder}/${name}
    printf -- "-->\n" >> ${folder}/${name}
    printf -- "<resources xmlns:xliff=\"urn:oasis:names:tc:xliff:document:1.2\">\n" >> ${folder}/${name}
}

function update_header () {
    local name=${1}

    # Use xliff document 1.2 namespace
    sed -i "s/.*<resources.*/<resources xmlns:xliff=\"urn:oasis:names:tc:xliff:document:1.2\">/g" ${folder}/${name}
    if [[ -z $(sed -n "/?xml/p" ${folder}/${name}) ]]; then
        sed -i "1 i\<?xml version=\"1.0\" encoding=\"utf-8\"?>" ${folder}/${name}
    fi
    if [[ -z $(sed -n "/Copyright (C)/p" ${folder}/${name}) ]]; then
        sed -i "2 i\-->" ${folder}/${name}
        sed -i "2 i\     SPDX-License-Identifier: Apache-2.0" ${folder}/${name}
        sed -i "2 i\     Copyright (C) $(date +%Y) The LineageOS Project" ${folder}/${name}
        sed -i "2 i\<!--" ${folder}/${name}
    fi
}

function open_resource_file () {
    local name=${1}
    sed -i "/<\/resources>/d" ${folder}/${name}
}

function close_resource_file () {
    local name=${1}
    if xmllint --format ${file} &> /dev/null || [[ ! -z $(tail -n 1 ${folder}/${name} | sed -n "/<\/resources>/p") ]]; then
        return
    fi
    printf "</resources>\n" >> ${folder}/${name}
}

function trim_file () {
    local name=${1}
    sed -ni "/[ ]*<[a-Z0-9/].*/p" ${folder}/${name}
}

for folder in $(find ${RRO_DIR}/res -maxdepth 1 -mindepth 1 -type d); do
    # Prepare files
    for file in $(find ${folder} -maxdepth 1 -mindepth 1 -type f -name "*.xml"); do
        trim_file $(basename ${file})
        open_resource_file $(basename ${file})
    done

    # Move the resources into files matching the aosp location
    for file in $(find ${folder} -maxdepth 1 -mindepth 1 -type f -name "*.xml"); do
        if [[ ! -z $(sed -n "/.*<[-a-Z]*array.*/p" ${file}) ]]; then
            echo "$file contains arrays, don't move it's content" > ${log}
            continue
        fi
        for name in $(grep -r "name=" ${file} | sed "s/[<>]/ /g" | sed "s/\"/\\\\\"/g" | awk '{print $2}'); do
            if ! grep -qr ${name} ${SRC_DIR}; then
                echo "[$(basename ${RRO_DIR})] Resource $(echo ${name} | sed "s/.*\"\([a-Z0-9_.]\+\)\\\.*/\1/g") not found in $(echo ${SRC_DIR} | sed "s/$(echo ${ANDROID_ROOT}/ | sed "s/\//\\\\\//g")//g")"
                continue
            fi

            get_src_path
            if [[ ! -f ${src_path} ]]; then
                echo "src_path: $src_path does not exist, skipping" > ${log}
                continue
            fi

            destination_filename=$(basename ${src_path})
            if [[ $(basename ${file}) == ${destination_filename} ]]; then
                continue
            fi

            # Create file if necessary
            init_file ${destination_filename}

            # Move the string into the file
            sed -n "/${name}/p" ${file} >> ${folder}/${destination_filename}
            sed -i "/${name}/d" ${file}
        done
    done

    # Sort the files
    for file in $(find ${folder} -maxdepth 1 -mindepth 1 -type f -name "*.xml"); do
        close_resource_file $(basename ${file})

        if [[ -z $(sed -n "/name=\"/p" ${file}) ]]; then
            echo "${file} is empty after moving resources, remove it" > ${log}
            rm ${file}
            continue
        fi

        update_header $(basename ${file})

        if ! xmllint --format ${file} &> /dev/null; then
            echo "${file} is not a valid XML, broke the rro"
            continue
        fi

        if [[ ! -z $(sed -n "/.*<[-a-Z]*array.*/p" ${file}) ]]; then
            echo "$file contains arrays, don't sort it" > ${log}
            add_aosp_comments ${file}
            continue
        fi

        for name in $(grep -r "name=" ${file} | sed "s/[<>]/ /g" | sed "s/\"/\\\\\"/g" | awk '{print $2}'); do
            get_src_path
            if [[ ! -f ${src_path} ]]; then
                line=0
            else
                line=$(grep -Pn -m 1 "${name}" ${src_path} | grep -Po "^[0-9]+")
            fi

            # Temporary add line number as prefix to the line to sort it
            sed -i "s/\(.*${name}.*\)/${line}\1/g" ${file}
        done

        # Sort the resources according to their line numbers in aosp
        first_real_line=$(grep -Pn -m 1 "<[-A-Za-z]+ name=" ${file} | grep -Po "^[0-9]+")
        (head -n $(expr ${first_real_line} - 1) ${file} && (tail -n+${first_real_line} ${file} | head -n -1) | LC_ALL=c sort && tail -n 1 ${file}) | sponge ${file}

        # Drop the line number prefix again
        sed -i "s/[0-9]\+\(    .*\)/\1/g" ${file}

        add_aosp_comments ${file}
    done
done

# Add copyright to AndroidManifest.xml and Android.bp
if [[ ! -z $(head -n 1 ${RRO_DIR}/AndroidManifest.xml | sed -n "/<manifest/p") ]]; then
    sed -i "1 i\-->" ${RRO_DIR}/AndroidManifest.xml
    sed -i "1 i\     SPDX-License-Identifier: Apache-2.0" ${RRO_DIR}/AndroidManifest.xml
    sed -i "1 i\     Copyright (C) $(date +%Y) The LineageOS Project" ${RRO_DIR}/AndroidManifest.xml
    sed -i "1 i\<!--" ${RRO_DIR}/AndroidManifest.xml
fi
if [[ ! -z $(head -n 1 ${RRO_DIR}/Android.bp | sed -n "/runtime_resource_overlay/p") ]]; then
    sed -i '1i\\' ${RRO_DIR}/Android.bp
    sed -i "1 i\\/\/" ${RRO_DIR}/Android.bp
    sed -i "1 i\\/\/ SPDX-License-Identifier: Apache-2.0" ${RRO_DIR}/Android.bp
    sed -i "1 i\\/\/" ${RRO_DIR}/Android.bp
    sed -i "1 i\\/\/ Copyright (C) $(date +%Y) The LineageOS Project" ${RRO_DIR}/Android.bp
    sed -i "1 i\\/\/" ${RRO_DIR}/Android.bp
fi

# Clear the temporary working directory
rm -rf "${TMPDIR}"
