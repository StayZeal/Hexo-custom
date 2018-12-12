---
title: adb获取root权限----adb常用命令集合
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
<!--more-->
##### 二、其他常用命令
`adb ls 、adb ls -l` 列表显示文件目录
`adb devices`显示连接的设备
`adb logcat` 显示日志
`adb install *.apk` 安装指定的apk
`adb -r install  *.apk` 强制安装指定apk
`adb -t install *.apk` 以Debug模式安装指定apk
`adb shell pm path packageName` 显示packageName的安装位置
`adb shell pm clear packageName` 清除packageName的本地缓存 
`adb shell pm dump packageName > aaaa.txt` 把相关包名信息打印到aaaa.txt(linux)
`adb shell pm list packages packageName` 打印软件包名称中包含packageName的软件包。
`adb shell am startservice com.test/MyService` 启动MyService服务

##### 三、常见问题
1、`Failed to push selection: couldn't create file: Permission denied`已经指定文件权限为777，但是在push文件的时候还是出报异常？
>解决：
>adb root //先获取root权限
>adb push 文件 /data //把文件push到data目录下
