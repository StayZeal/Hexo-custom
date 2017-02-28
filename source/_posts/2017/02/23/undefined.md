---
title: Android��Ļ���ȵ���
date: 2017-02-23 12:12:47
tags:
---
Android��Ļ���ȵ��ڷ����֣�
1.���ڵ�ǰActivity�����ȣ����˳���Activity�Ϳ��Իָ���ϵͳĬ�����ȡ�

```java
Window window = getWindow();
WindowManager.LayoutParams mParams = window.getAttributes();
//brightnessֵ:0-1
mParams.screenBrightness = brightness;
window.setAttributes(mParams);
```

2.����ϵͳ����Ļ���ȣ���Activity�޹ء�

```java
//value ֵ��0-255
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
                    screenBrightnessTv.setText("ϵͳ���ȣ�" + (int) brightness);
                } else {
                    float brightness = progress / 100f;
                    setBrightness(brightness);
                    screenBrightnessTv.setText("Activity���ȣ�" + brightness);
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
         * ��һ�λ�ȡ��ֵΪ-1,��ʾ����ϵͳ����
         */
        Log.i(TAG, "Attributes:" + mParams.screenBrightness + "");

        try {

            /**
             * ��õ�ǰ��Ļ���ȵ�ģʽ
             * SCREEN_BRIGHTNESS_MODE_AUTOMATIC=1 Ϊ�Զ�������Ļ����
             * SCREEN_BRIGHTNESS_MODE_MANUAL=0 Ϊ�ֶ�������Ļ����
             */
            screenMode = Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS_MODE);
            Log.i(TAG, "screenMode = " + screenMode);
            // ��õ�ǰ��Ļ����ֵ 0--255
            screenBrightness = Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
            Log.i(TAG, "Global screenBrightness = " + screenBrightness);

        } catch (Settings.SettingNotFoundException e) {
            e.printStackTrace();
        }
    }


    /**
     * @param brightness:0.0f-1.0f���Ϊ������ʾ����ϵͳ���ȣ�
     *                   ����window.setAttributes(mParams)����ı�����Activity�������Լ�ϵͳ����
     *                   --Settings.System.getInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS����ֵ�����;
     */
    private void setBrightness(float brightness) {
        mParams.screenBrightness = brightness;
        window.setAttributes(mParams);
    }

    /**
     * @param mode 1:�Զ��������ȣ�0Ϊ�ֶ���������
     *             ��Ҫ <uses-permission android:name="android.permission.WRITE_SETTINGS" />��Ȩ��
     */
    private void setBrightnessMode(int mode) {
        Settings.System.putInt(getContentResolver(), Settings.System.SCREEN_BRIGHTNESS_MODE, mode);
    }


    /**
     * @param brightness 0-255
     */
    private void setGlobalBrightness(int brightness) {
        if (BuildConfig.VERSION_CODE < Build.VERSION_CODES.M) {//6.0ϵͳ���¸ı�ϵͳ��Ļ������Ҫ��������ģʽΪ�ֶ�����
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
        android:text="Ĭ�����ȣ�����ϵͳ��" />

    <Button
        android:id="@+id/max_Btn"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="�������" />


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
            android:text="ϵͳ" />
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
        android:text="����" />

</LinearLayout>

```