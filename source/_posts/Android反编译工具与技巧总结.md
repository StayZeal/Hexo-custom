---
title: Android反编译工具与技巧总结
date: 2018-01-12 17:32:58
tags:
     - Android
     - 反编译
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)
<!--more-->
**相关工具：**
- [apktool](https://ibotpeaches.github.io/Apktool/) 
` java -jar apktool.jar d ssss.apk`
1、反编译dex -> smali文件
2、res文件夹可读
3、AndroidManifest.xml文件可读
R.java文件对应的值在res/values/public.xml文件里
- [dex2jar](https://sourceforge.net/projects/dex2jar/)
将dex文件反编译成jar文件
- [Jadx](https://github.com/skylot/jadx)
反编译dex，转成java文件，
优点：**能够查找方法的引用**
- [jd-gui]()
反编译dex，转成java文件
优点：速度快
缺点：部分类可能会反编译失败
- [luyten]() 同上
遇到部分类反编译失败Jd-gui，Jadx，Luyten可以结合使用
- [动态调试smali](https://bbs.pediy.com/thread-220743.html)

以上工具的具体使用方法请百度。

**相关技巧：**
- 查看当前Activity信息：
1、通过如下命令你可以快速的定位到当前页面所对应的Activity：
    ` adb shell dumpsys activity top`
2、使用如下工具，通过View Id 查找引用View的相关Activity，也可以**分析当前页面的的布局结构**：
![image.png](http://upload-images.jianshu.io/upload_images/800897-9f71440395228bd7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
View Id 可能需要现在R.java或者public.xml查找对应的10进制或者16进制的值，然后才能在项目中找到。
微信可能做了资源混淆(或者以后遇到做了资源混淆的apk)的时候，如果发现通过public.xml中的id值查找不到结果，可以直接使用R.xxx.xxx进行查找id值。

- 使用Jadx进行方法跟踪时候如果发现没有结果，可能这个方法是抽象的，需要找到这个抽象方法最原始的定义的地方继续跟踪即可。


- 指定app安装器包名：
使用命令` pm install -i[指定安装器包名] apk文件`，这个命令可以指定一个app的安装器
- 快速在反编译的项目中找到自己想要的，除了掌握必要的反编译技巧，还需要会猜测和想象力。

博客推荐：编码美丽http://blog.csdn.net/jiangwei0910410003?viewmode=contents













