/*
 * Copyright (C) 2018 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.dolby;

import android.media.audiofx.AudioEffect;
import android.util.Log;

import java.util.UUID;

public class DolbyAtmos extends AudioEffect {

    private static final String TAG = "DolbyAtmos";
    private static final UUID EFFECT_TYPE_DAP =
            UUID.fromString("9d4921da-8225-4f29-aefa-39537a04bcaa");
    private static final int DAP_PARAM = 5;
    private static final int DAP_PARAM_PROFILE = 0xA000000;
    private static final int DAP_PARAM_VALUE = 0x1000000;
    private static final int DAP_PARAM_GEQ = 110;
    private static final int DAP_PARAM_VOLUME_LEVELER = 103;
    private static final int DAP_PROFILES_COUNT = 9;

    public DolbyAtmos(int priority, int audioSession) {
        super(EFFECT_TYPE_NULL, EFFECT_TYPE_DAP, priority, audioSession);
    }

    private static int int32ToByteArray(int value, byte[] buf, int offset) {
        buf[offset] = (byte) (value & 255);
        buf[offset + 1] = (byte) ((value >>> 8) & 255);
        buf[offset + 2] = (byte) ((value >>> 16) & 255);
        buf[offset + 3] = (byte) ((value >>> 24) & 255);
        return 4;
    }

    private static int byteArrayToInt32(byte[] buf) {
        return (buf[0] & 255) | ((buf[3] & 255) << 24)
                | ((buf[2] & 255) << 16) | ((buf[1] & 255) << 8);
    }

    private static int int32ArrayToByteArray(int[] values, byte[] buf, int offset) {
        for (int value : values) {
            buf[offset] = (byte) ((value >>> 0) & 255);
            buf[offset + 1] = (byte) ((value >>> 8) & 255);
            buf[offset + 2] = (byte) ((value >>> 16) & 255);
            buf[offset + 3] = (byte) ((value >>> 24) & 255);
            offset += 4;
        }
        return values.length << 2;
    }

    private void setIntParam(int param, int value) {
        byte[] buf = new byte[12];
        int i = int32ToByteArray(param, buf, 0);
        int32ToByteArray(value, buf, i + int32ToByteArray(1, buf, i));
        checkStatus(setParameter(DAP_PARAM, buf));
    }

    private int getIntParam(int param) {
        byte[] buf = new byte[12];
        int32ToByteArray(param, buf, 0);
        checkStatus(getParameter(DAP_PARAM + param, buf));
        return byteArrayToInt32(buf);
    }

    private void setDapParameter(int param, int values[]) {
        for (int profile = 0; profile < DAP_PROFILES_COUNT; profile++) {
            int length = values.length;
            byte[] buf = new byte[(length + 4) * 4];
            int i = int32ToByteArray(DAP_PARAM_VALUE, buf, 0);
            int i2 = i + int32ToByteArray(length + 1, buf, i);
            int i3 = i2 + int32ToByteArray(profile, buf, i2);
            int32ArrayToByteArray(values, buf, i3 + int32ToByteArray(param, buf, i3));
            checkStatus(setParameter(DAP_PARAM, buf));
        }
    }

    public void setDsOn(boolean on) {
        setIntParam(0, on ? 1 : 0);
        super.setEnabled(on);
    }

    public boolean getDsOn() {
        return getIntParam(0) == 1;
    }

    public void setProfile(int index) {
        setIntParam(DAP_PARAM_PROFILE, index);
    }

    public int getProfile() {
        return getIntParam(DAP_PARAM_PROFILE);
    }

    public void setGeqBandGains(int[] gains) {
        setDapParameter(DAP_PARAM_GEQ, gains);
    }

    public void setVolumeLevelerEnabled(boolean enable) {
        setDapParameter(DAP_PARAM_VOLUME_LEVELER, new int[]{enable ? 1 : 0});
    }
}
