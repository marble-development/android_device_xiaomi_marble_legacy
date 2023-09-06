/*
 * Copyright (C) 2023 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.settings.display;

import static android.provider.Settings.System.DISPLAY_COLOR_MODE;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.IBinder;
import android.os.SystemProperties;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Log;

import java.util.Map;

import vendor.xiaomi.hardware.displayfeature.V1_0.IDisplayFeature;

public class ColorService extends Service {
    private static final String TAG = "ColorService";
    private static final boolean DEBUG = true;

    private static final int DEFAULT_COLOR_MODE = SystemProperties.getInt(
            "persist.sys.sf.native_mode", 0);

    /* color mode -> displayfeature (mode, value, cookie) */
    private static final Map<Integer, DfParams> COLOR_MAP = Map.of(
        258 /* vivid */, new DfParams(0, 2, 255),
        256 /* saturated */, new DfParams(1, 2, 255),
        257 /* standard */, new DfParams(2, 2, 255),
        269 /* original */, new DfParams(26, 1, 0),
        268 /* p3 */, new DfParams(26, 2, 0),
        267 /* srgb */, new DfParams(26, 3, 0)
    );
    /* original/p3/srgb */
    private static final int EXPERT_MODE = 26;
    private static final DfParams EXPERT_PARAMS = new DfParams(26, 0, 10);

    private IDisplayFeature mDisplayFeature;

    private final ContentObserver mSettingObserver = new ContentObserver(new Handler()) {
        @Override
        public void onChange(boolean selfChange) {
            dlog("SettingObserver: onChange");
            setCurrentColorMode();
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        dlog("onCreate");
        getContentResolver().registerContentObserver(Settings.System.getUriFor(DISPLAY_COLOR_MODE),
                    false, mSettingObserver, UserHandle.USER_CURRENT);
        setCurrentColorMode();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        dlog("onStartCommand");
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        dlog("onDestroy");
        getContentResolver().unregisterContentObserver(mSettingObserver);
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public static void startService(Context context) {
        context.startServiceAsUser(new Intent(context, ColorService.class), UserHandle.CURRENT);
    }

    private void setCurrentColorMode() {
        final int colorMode = Settings.System.getIntForUser(getContentResolver(),
                DISPLAY_COLOR_MODE, DEFAULT_COLOR_MODE, UserHandle.USER_CURRENT);
        if (!COLOR_MAP.containsKey(colorMode)) {
            Log.e(TAG, "setCurrentColorMode: " + colorMode + " is not in colorMap!");
            return;
        }
        final DfParams params = COLOR_MAP.get(colorMode);
        dlog("setCurrentColorMode: " + colorMode + ", params=" + params);
        if (params.mode == EXPERT_MODE) {
            setDisplayFeatureParams(EXPERT_PARAMS);
        }
        setDisplayFeatureParams(params);
    }

    private void setDisplayFeatureParams(DfParams params) {
        final IDisplayFeature displayFeature = getDisplayFeature();
        if (displayFeature == null) {
            Log.e(TAG, "setDisplayFeatureParams: displayFeature is null!");
            return;
        }
        dlog("setDisplayFeatureParams: " + params);
        try {
            displayFeature.setFeature(0, params.mode, params.value, params.cookie);
        } catch (Exception e) {
            Log.e(TAG, "setDisplayFeatureParams failed!", e);
        }
    }

    private IDisplayFeature getDisplayFeature() {
        if (mDisplayFeature == null) {
            dlog("getDisplayFeature: mDisplayFeature=null");
            try {
                mDisplayFeature = IDisplayFeature.getService();
            } catch (Exception e) {
                Log.e(TAG, "getDisplayFeature failed!", e);
            }
        }
        return mDisplayFeature;
    }

    private static void dlog(String msg) {
        if (DEBUG) Log.d(TAG, msg);
    }

    private static class DfParams {
        /* displayfeature parameters */
        final int mode, value, cookie;

        DfParams(int mode, int value, int cookie) {
            this.mode = mode;
            this.value = value;
            this.cookie = cookie;
        }

        public String toString() {
            return "DisplayFeatureParams(" + mode + ", " + value + ", " + cookie + ")";
        }
    }
}
