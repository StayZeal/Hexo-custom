---
title: Android Studio动态调试Smail踩坑
date: 2018-05-15 17:32:58
tags:
     - Android
     - 反编译
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)
#### 说明：
在进行Apk逆向的时候，有时候静态分析无法满足我们的需求，我们需要进行动态调试，分为调试Smali和so文件，这里讨论调试Smali的方法。
<!--more-->
#### 要点：
-  Android Stuido 安装smalidea
- apk需要**可调试**即需要反编译和二次打包
- 以调试模式启动app
- 通过ddms获取调试端口
- 新建远程调试

#### 步骤：
**1、安装smalidea，并安装到AS（如下图所示，安装玩需要重启AS），**下载：https://github.com/JesusFreke/smali/wiki/smalidea
![image.png](https://upload-images.jianshu.io/upload_images/800897-ea69fafa389e467c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**2、使用apltool反编译A.apk** 
>apktool d A.apk


**3、通过AS导入项目**
![image.png](https://upload-images.jianshu.io/upload_images/800897-b5e00f2ba9a2a8d5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
**4、AndroidManifest.xml文件中application标签中添加` android:debuggable="true"`**
**5、apktool重新打包**
>apktool b  目录名 out -o apkname.apk


**6、使用keystore进行签名(需要根据你自己的签名修改命令)**
>jarsigner -verbose  -keystore stayzeal.keystore -storepass stayzeal -signedjar debug_signed.apk debug.apk mykey(别名)


**7、安装重新打包的apk，并以调试模式启动**
>adb shell am start -D -n app包名/WelComeActivity


**8、打开ddms，查看调试端口**
>//如果Android Studio找不到，可以在如下目录下寻找monitor.bat点击运行
>\sdk\tools\monitor.bat

![image.png](https://upload-images.jianshu.io/upload_images/800897-99cd450138a7c28f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


**9、新建remote调试**
![image.png](https://upload-images.jianshu.io/upload_images/800897-4e681ad56d38605f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/800897-a1f09a964b904acf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


**10、debug按钮开始调试**
![image.png](https://upload-images.jianshu.io/upload_images/800897-430da0609035c510.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 可能遇到的问题
- 签名校验导致程序闪退 

#### 文章环境
Android Studio 3.0.1/3.1.2<br>
[smalidea-0.05.zip](https://bitbucket.org/JesusFreke/smali/downloads/smalidea-0.05.zip)
















