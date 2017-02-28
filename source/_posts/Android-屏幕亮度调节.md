---
title: Android 屏幕亮度调节
date: 2017-02-22 17:32:58
tags:
---
Android屏幕亮度调节分两种：
1.调节当前Activity的亮度，当退出该Activity就可以恢复到系统默认亮度。

```java
Window window = getWindow();
WindowManager.LayoutParams mParams = window.getAttributes();
//brightness值:0-1
mParams.screenBrightness = brightness;
window.setAttributes(mParams);
```

2.调节系统的屏幕亮度，跟Activity无关。

```java
//value 值：0-255
Settings.System.putInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS, value);  
```
Demo:

```java

import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.SeekBar;
import android.widget.TextView;

import com.example.androidtest.BuildConfig;
import com.example.androidtest.R;

import butterknife.Bind;
import butterknife.ButterKnife;
import butterknife.OnClick;


public class BrightnessActivity extends AppCompatActivity {


    private static final String TAG = "BrightnessActivity";
    Window window;
    @Bind(R.id.default_Btn)
    Button defaultBtn;
    @Bind(R.id.max_Btn)
    Button maxBtn;
    @Bind(R.id.exchange_Sb)
    SeekBar exchangeSb;
    @Bind(R.id.screen_brightness_Tv)
    TextView screenBrightnessTv;
    @Bind(R.id.activity_Rb)
    RadioButton activityRb;
    @Bind(R.id.system_Rb)
    RadioButton systemRb;
    @Bind(R.id.radio_group)
    RadioGroup radioGroup;
    private WindowManager.LayoutParams mParams;
    private int screenBrightness;
    private int screenMode;
    private boolean isSystem = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_brightness);
        ButterKnife.bind(this);

        window = getWindow();
        getBrightNess();
        exchangeSb.setProgress((int) (screenBrightness / 255.0f * 100));
        Log.i(TAG, "progress:" + exchangeSb.getProgress());

        radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                switch (checkedId) {
                    case R.id.activity_Rb:
                        isSystem = false;
                        break;
                    case R.id.system_Rb:
                        isSystem = true;
                        break;
                }
            }
        });

        exchangeSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (isSystem) {
                    float brightness = progress / 100f * 255;
                    setGlobalBrightness((int) brightness);
                    screenBrightnessTv.setText("系统亮度：" + (int) brightness);
                } else {
                    float brightness = progress / 100f;
                    setBrightness(brightness);
                    screenBrightnessTv.setText("Activity亮度：" + brightness);
                }

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });


    }

    @OnClick({R.id.default_Btn, R.id.max_Btn})
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.default_Btn:
                setBrightness(-1.0f);
                getBrightNess();
                break;
            case R.id.max_Btn:
                setBrightness(1.0f);
                getBrightNess();
                break;
        }
    }


    private void getBrightNess() {

        mParams = window.getAttributes();
        /**
         * 第一次获取这值为-1,表示跟随系统亮度
         */
        Log.i(TAG, "Attributes:" + mParams.screenBrightness + "");

        try {

            /**
             * 获得当前屏幕亮度的模式
             * SCREEN_BRIGHTNESS_MODE_AUTOMATIC=1 为自动调节屏幕亮度
             * SCREEN_BRIGHTNESS_MODE_MANUAL=0 为手动调节屏幕亮度
             */
            screenMode = Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS_MODE);
            Log.i(TAG, "screenMode = " + screenMode);
            // 获得当前屏幕亮度值 0--255
            screenBrightness = Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
            Log.i(TAG, "Global screenBrightness = " + screenBrightness);

        } catch (Settings.SettingNotFoundException e) {
            e.printStackTrace();
        }
    }


    /**
     * @param brightness:0.0f-1.0f如果为负数表示跟随系统亮度，
     *                   单纯window.setAttributes(mParams)不会改变其他Activity的亮度以及系统亮度
     *                   --Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS）的值不会变;
     */
    private void setBrightness(float brightness) {
        mParams.screenBrightness = brightness;
        window.setAttributes(mParams);
    }

    /**
     * @param mode 1:自动调节亮度，0为手动调节亮度
     *             需要 <uses-permission android:name="android.permission.WRITE_SETTINGS" />”权限
     */
    private void setBrightnessMode(int mode) {
        Settings.System.putInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS_MODE, mode);
    }


    /**
     * @param brightness 0-255
     */
    private void setGlobalBrightness(int brightness) {
        if (BuildConfig.VERSION_CODE < Build.VERSION_CODES.M) {//6.0系统以下改变系统屏幕亮度需要设置亮度模式为手动调节
            setBrightnessMode(0);
        }
        Settings.System.putInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS, brightness);
    }


}

```

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:paddingBottom="@dimen/activity_vertical_margin"
    android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    tools:context="com.example.androidtest.activity.BrightnessActivity">

    <Button
        android:id="@+id/default_Btn"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="默认亮度（跟随系统）" />

    <Button
        android:id="@+id/max_Btn"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="最大亮度" />


    <RadioGroup
        android:id="@+id/radio_group"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="40dp"
        android:orientation="horizontal">

        <RadioButton
            android:id="@+id/activity_Rb"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:checked="true"
            android:text="Activity" />

        <RadioButton
            android:id="@+id/system_Rb"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="系统" />
    </RadioGroup>

    <SeekBar
        android:id="@+id/exchange_Sb"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="20dp" />

    <TextView
        android:id="@+id/screen_brightness_Tv"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:layout_marginTop="40dp"
        android:text="亮度" />

</LinearLayout>

```