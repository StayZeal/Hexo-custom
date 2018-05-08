---
title: adb 获取root权限----adb命令集合
date: 2015-10-12 17:32:58
tags:
       - adb
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

##### 一、获取root权限，给文件以读写权限
步骤：
>1、手机进行root；
2、cmd 进入命令行 运行 adb shell命令（adb 已配置到环境变量中），此时命令变成$开头；
3、运行 su 命令，切换到root权限，此时命令变成#开头；
4、运行 chmod  777命令，后边跟文件路径，给文件读写权限。

##### 二、其他常用命令
1、adb ll 、adb ls -l列表显示文件目录
2、adb devices 显示连接的设备
3、adb logcat 显示日志
4、adb install *.apk安装指定的apk，adb -r install  *.apk强制安装指定apk

##### 三、常见问题
1、`Failed to push selection: couldn't create file: Permission denied`已经指定文件权限为777，但是在push文件的时候还是出报异常？
>解决：
>adb root //先获取root权限
>adb push 文件 /data //把文件push到data目录下