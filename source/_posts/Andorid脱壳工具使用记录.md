---
title: Andorid脱壳工具使用记录
date: 2018-04-11 17:32:58
tags:
     - Java
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

# **[IDA]()**（动态调试)
- 原理：dvm虚拟机函数下断点，dump出dex文件
- 不支持Andorid 5.0（ART虚拟机找不到函数断点位置）
<!--more-->
# **[drizzleDumper](https://github.com/DrizzleRisk/drizzleDumper)**（有源码，停止更新）
- 原理：drizzleDumper工作的原理是root环境下，通过ptrace附加需要脱壳的apk进程，然后在脱壳的apk进程的内存中进行dex文件的特征搜索，当搜索到dex文件时，进行dex文件的内存dump。
- 使用：手机需要root，可真机，可模拟器
- 用法：github下载源码
```
cd drizzleDumper-master\libs\armeabi/drizzleDumper  //arm
adb push drizzleDumper /data/local/tmp  
adb shell chmod 0777 /data/local/tmp/drizzleDumper  
  
adb shell                       //进入androd系统的shell  
su                          //获取root权限  
./data/local/tmp/drizzleDumper com.qihoo.freewifi 2 #执行脱壳操作  
```
参考：http://blog.csdn.net/qq1084283172/article/details/53561622
- 不支持：百度加固 (Android 5.0)
```
错误： The magic was Not Found!
```
# **[GDA](http://www.gda.wiki:9090/)**(无源码，停止更新)
- 原理：dump出dex文件
- 用法：https://zhuanlan.zhihu.com/p/26341224
- 不支持：64位CPU，Andorid 5.0
```
错误：error: only position independent executables
```