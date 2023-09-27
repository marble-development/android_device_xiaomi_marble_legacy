/*
 * MIT License
 *
 * Copyright (c) 2021 Trần Mạnh Cường <maytinhdibo>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package io.github.maytinhdibo.pocket;

import android.app.AlarmManager;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.SystemClock;
import android.util.Log;

import io.github.maytinhdibo.pocket.receiver.PhoneStateReceiver;

public class PocketService extends Service {
    private static final String TAG = "PocketMode";
    private static final boolean DEBUG = true;

    private static final int EVENT_UNLOCK = 2;
    private static final int EVENT_TURN_ON_SCREEN = 1;
    private static final int EVENT_TURN_OFF_SCREEN = 0;

    private int lastAction = -1;
    private static long nextAlarm = -1;
    private boolean isSensorRunning = false;

    SensorManager sensorManager;
    Sensor proximitySensor;
    Context mContext;

    private long lastBlock = -1;
    private boolean isFirstChange = false;

    @Override
    public void onCreate() {
        if (DEBUG) Log.d(TAG, "Creating service");
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        proximitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);

        mContext = this;

        IntentFilter screenStateFilter = new IntentFilter();
        screenStateFilter.addAction(Intent.ACTION_SCREEN_ON);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_OFF);
        screenStateFilter.addAction(Intent.ACTION_USER_PRESENT);
        registerReceiver(mScreenStateReceiver, screenStateFilter);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (DEBUG) Log.d(TAG, "Starting service");
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        if (DEBUG) Log.d(TAG, "Destroying service");
        this.unregisterReceiver(mScreenStateReceiver);
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void disableSensor() {
        if (!isSensorRunning) return;
        if (DEBUG) Log.d(TAG, "Disable proximity sensor");
        sensorManager.unregisterListener(proximitySensorEventListener, proximitySensor);
        //mark first sensor update after disable
        isFirstChange = true;
        isSensorRunning = false;
    }

    private void enableSensor() {
        if (DEBUG) Log.d(TAG, "Enable proximity sensor");
        sensorManager.registerListener(proximitySensorEventListener,
                proximitySensor,
                SensorManager.SENSOR_DELAY_NORMAL);
        isSensorRunning = true;
    }

    private BroadcastReceiver mScreenStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Intent.ACTION_SCREEN_ON)) {
                if (lastAction != EVENT_UNLOCK) enableSensor();
                lastAction = EVENT_TURN_ON_SCREEN;
            } else if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF)) {
                disableSensor();

                //save alarm after turn off screen
                AlarmManager alarmManager = (AlarmManager) getSystemService(ALARM_SERVICE);
                AlarmManager.AlarmClockInfo alarmClockInfo = alarmManager.getNextAlarmClock();
                if (alarmClockInfo != null) nextAlarm = alarmClockInfo.getTriggerTime();
                else nextAlarm = -1;

                lastAction = EVENT_TURN_OFF_SCREEN;
            } else if (intent.getAction().equals(Intent.ACTION_USER_PRESENT)) {
                //disable when unlocked
                disableSensor();
                lastAction = EVENT_UNLOCK;
            }
        }
    };

    SensorEventListener proximitySensorEventListener = new SensorEventListener() {
        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
            //method to check accuracy changed in sensor.
        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            //check if the sensor type is proximity sensor.
            if (event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
                if (event.values[0] == 0) {
                    long timestamp = System.currentTimeMillis();
                    if (PhoneStateReceiver.CUR_STATE == PhoneStateReceiver.IDLE
                            && (nextAlarm == -1 || timestamp - nextAlarm > 60000)) {
                        //stop block turn on after 15 seconds
                        if (!(isFirstChange && (System.currentTimeMillis() - lastBlock < 15000 && lastBlock != -1))) {
                            if (DEBUG) Log.d(TAG, "NEAR, disable sensor and turn screen off");
                            disableSensor();
                            PowerManager pm = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
                            if (pm != null) {
                                pm.goToSleep(SystemClock.uptimeMillis());
                                lastBlock = System.currentTimeMillis();
                            }
                        }
                    }
                } else {
                    if (DEBUG) Log.d(TAG, "FAR");
                }
            }
            isFirstChange = false;
        }
    };
}
