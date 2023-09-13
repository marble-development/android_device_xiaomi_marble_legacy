/*
 * Copyright (C) 2018,2020 The LineageOS Project
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

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.media.session.MediaController;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.os.Handler;
import android.os.SystemClock;
import android.os.UserHandle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.KeyEvent;

import org.lineageos.settings.R;

import java.util.Arrays;
import java.util.List;

public final class DolbyUtils {

    private static final String TAG = "DolbyUtils";
    private static final String DEFAULT_PRESET = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
    private static final int EFFECT_PRIORITY = 100;

    private static DolbyUtils mInstance;
    private DolbyAtmos mDolbyAtmos;
    private MediaSessionManager mMediaSessionManager;
    private Context mContext;
    private Handler mHandler = new Handler();

    private DolbyUtils(Context context) {
        mContext = context;
        mDolbyAtmos = new DolbyAtmos(EFFECT_PRIORITY, 0);
        mMediaSessionManager = context.getSystemService(MediaSessionManager.class);
    }

    public static synchronized DolbyUtils getInstance(Context context) {
        if (mInstance == null) {
            mInstance = new DolbyUtils(context);
        }
        return mInstance;
    }

    public void onBootCompleted() {
        Log.i(TAG, "onBootCompleted");
        mDolbyAtmos.setEnabled(mDolbyAtmos.getDsOn());
        mDolbyAtmos.setVolumeLevelerEnabled(false);

        // // Make sure to apply our configuration
        // SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(mContext);
        // boolean dsOn = prefs.getBoolean(DolbySettingsFragment.PREF_ENABLE, true);
        // if (!dsOn) {
        //     // Skip if dolby is off, maybe controlled by other dax app
        //     Log.i(TAG, "dolby is off, skip configuration");
        //     return;
        // }
        // int profile = Integer.parseInt(prefs.getString(
        //         DolbySettingsFragment.PREF_PROFILE, "0" /* dynamic */));
        // String preset = prefs.getString(DolbySettingsFragment.PREF_PRESET, DEFAULT_PRESET);
        // setDsOn(dsOn);
        // setProfile(profile);
        // setPreset(preset);
    }

    private void triggerPlayPause(MediaController controller) {
        long when = SystemClock.uptimeMillis();
        final KeyEvent evDownPause = new KeyEvent(when, when, KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PAUSE, 0);
        final KeyEvent evUpPause = KeyEvent.changeAction(evDownPause, KeyEvent.ACTION_UP);
        final KeyEvent evDownPlay = new KeyEvent(when, when, KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY, 0);
        final KeyEvent evUpPlay = KeyEvent.changeAction(evDownPlay, KeyEvent.ACTION_UP);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                controller.dispatchMediaButtonEvent(evDownPause);
            }
        });
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                controller.dispatchMediaButtonEvent(evUpPause);
            }
        }, 20);
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                controller.dispatchMediaButtonEvent(evDownPlay);
            }
        }, 1000);
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                controller.dispatchMediaButtonEvent(evUpPlay);
            }
        }, 1020);
    }

    private int getMediaControllerPlaybackState(MediaController controller) {
        if (controller != null) {
            final PlaybackState playbackState = controller.getPlaybackState();
            if (playbackState != null) {
                return playbackState.getState();
            }
        }
        return PlaybackState.STATE_NONE;
    }

    private void refreshPlaybackIfNecessary(){
        if (mMediaSessionManager == null) return;

        final List<MediaController> sessions
                = mMediaSessionManager.getActiveSessionsForUser(
                null, UserHandle.ALL);
        for (MediaController controller : sessions) {
            if (PlaybackState.STATE_PLAYING ==
                    getMediaControllerPlaybackState(controller)) {
                triggerPlayPause(controller);
                break;
            }
        }
    }

    private void checkEffect() {
        if (!mDolbyAtmos.hasControl()) {
            Log.w(TAG, "lost control, recreating effect");
            mDolbyAtmos.release();
            mDolbyAtmos = new DolbyAtmos(EFFECT_PRIORITY, 0);
        }
    }

    public void setDsOn(boolean on) {
        checkEffect();
        Log.i(TAG, "setDsOn: " + on);
        mDolbyAtmos.setDsOn(on);
        refreshPlaybackIfNecessary();
    }

    public boolean getDsOn() {
        boolean on = mDolbyAtmos.getDsOn();
        Log.i(TAG, "getDsOn: " + on);
        return on;
    }

    public void setProfile(int index) {
        checkEffect();
        Log.i(TAG, "setProfile: " + index);
        mDolbyAtmos.setProfile(index);
    }

    public int getProfile() {
        int profile = mDolbyAtmos.getProfile();
        Log.i(TAG, "getProfile: " + profile);
        return profile;
    }

    public String getProfileName() {
        String profile = Integer.toString(mDolbyAtmos.getProfile());
        List<String> profiles = Arrays.asList(mContext.getResources().getStringArray(
                R.array.dolby_profile_values));
        int profileIndex = profiles.indexOf(profile);
        Log.i(TAG, "getProfileAsString: profile=" + profile + " index=" + profileIndex);
        return profileIndex == -1 ? null : mContext.getResources().getStringArray(
                R.array.dolby_profile_entries)[profileIndex];
    }

    public void setPreset(String preset) {
        checkEffect();
        int[] gains = Arrays.stream(preset.split(",")).mapToInt(Integer::parseInt).toArray();
        Log.i(TAG, "setPreset: " + Arrays.toString(gains));
        mDolbyAtmos.setGeqBandGains(gains);
    }
}
