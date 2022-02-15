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

package org.lineageos.settings.dirac;

import android.os.Bundle;
import android.widget.Switch;
import android.util.Log;

import androidx.preference.ListPreference;
import androidx.preference.Preference;
import androidx.preference.Preference.OnPreferenceChangeListener;
import androidx.preference.PreferenceFragment;
import androidx.preference.SwitchPreference;

import com.android.settingslib.widget.MainSwitchPreference;
import com.android.settingslib.widget.OnMainSwitchChangeListener;

import org.lineageos.settings.R;

public class DiracSettingsFragment extends PreferenceFragment implements
        OnPreferenceChangeListener, OnMainSwitchChangeListener {

    private static final String TAG = "DiracSettingsFragment";
    private static final String PREF_ENABLE = "dirac_enable";
    private static final String PREF_HEADSET = "dirac_headset_pref";
    private static final String PREF_HIFI = "dirac_hifi_pref";
    private static final String PREF_PRESET = "dirac_preset_pref";
    private static final String PREF_SCENE = "scenario_selection";

    private MainSwitchPreference mSwitchBar;

    private ListPreference mHeadsetType;
    private ListPreference mPreset;
    private SwitchPreference mHifi;
    private ListPreference mScenes;
    private DiracUtils mDiracUtils;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        addPreferencesFromResource(R.xml.dirac_settings);

        try {
            mDiracUtils = DiracUtils.getInstance(getActivity());
        } catch (Exception e) {
            Log.d(TAG, "Dirac is not present in system");
        }

        boolean enhancerEnabled = mDiracUtils != null ? mDiracUtils.isDiracEnabled() : false;
        mSwitchBar = (MainSwitchPreference) findPreference(PREF_ENABLE);
        mSwitchBar.addOnSwitchChangeListener(this);
        mSwitchBar.setChecked(enhancerEnabled);

        mHeadsetType = (ListPreference) findPreference(PREF_HEADSET);
        mHeadsetType.setOnPreferenceChangeListener(this);

        mPreset = (ListPreference) findPreference(PREF_PRESET);
        mPreset.setOnPreferenceChangeListener(this);

        mHifi = (SwitchPreference) findPreference(PREF_HIFI);
        mHifi.setOnPreferenceChangeListener(this);

        boolean hifiEnable = mDiracUtils != null ? mDiracUtils.getHifiMode() : false;
        mHeadsetType.setEnabled(!hifiEnable && enhancerEnabled);
        mPreset.setEnabled(!hifiEnable && enhancerEnabled);
        mHifi.setEnabled(enhancerEnabled);

        mScenes = (ListPreference) findPreference(PREF_SCENE);
        mScenes.setOnPreferenceChangeListener(this);
        mScenes.setEnabled(enhancerEnabled);
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (mDiracUtils == null) return false;
        switch (preference.getKey()) {
            case PREF_HEADSET:
                mDiracUtils.setHeadsetType(Integer.parseInt(newValue.toString()));
                return true;
            case PREF_HIFI:
                mDiracUtils.setHifiMode((Boolean) newValue ? 1 : 0);
                if (mDiracUtils.isDiracEnabled()) {
                    mHeadsetType.setEnabled(!(Boolean) newValue);
                    mPreset.setEnabled(!(Boolean) newValue);
                }
                return true;
            case PREF_PRESET:
                mDiracUtils.setLevel((String) newValue);
                return true;
            case PREF_SCENE:
                mDiracUtils.setScenario(Integer.parseInt(newValue.toString()));
                return true;
            default:
                return false;
        }
    }

    @Override
    public void onSwitchChanged(Switch switchView, boolean isChecked) {
        mSwitchBar.setChecked(isChecked);

        if (mDiracUtils == null) return;
        mDiracUtils.setEnabled(isChecked);
        mHifi.setEnabled(isChecked);
        mHeadsetType.setEnabled(isChecked);
        mPreset.setEnabled(isChecked);
        mScenes.setEnabled(isChecked);

        if (!isChecked) {
            mHifi.setChecked(false);
            mDiracUtils.setHifiMode(0);
        }
    }
}
