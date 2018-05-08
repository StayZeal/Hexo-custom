---
title: Win10改Win7,Win8 改Win7笔记
date: 2018-01-11 17:32:58
tags:
     - Win10
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

#### 吐槽：
Win10 UI挺漂亮的，能装Linux子系统，环境变量配置也比以前好看；但是BUG太多，自动更新占网速，鼠标键盘突然失灵，睡眠之后灰屏（蓝屏），底部菜单栏图标突然消失。Win10推出的秋季版和以前的版本差别也挺大的。
<!--more-->
#### 正文：

如果你的Win10系统能够使用的话，直接下载Win7 64位 的iso，解压运行setup，那么win7会自动开始安装。如果不能使用，同理用大白菜的装机工具，把win7 iso拷到硬盘上解压，运行setup。如果不能解压，那就拷贝一个解压工具。
win10或者win8降到win7系统可能会遇到的问题：
1、需要更改Bios，把UEFI改成兼容历史版本模式
2、格式化磁盘：GUID(GPT)改MBR
http://www.pconline.com.cn/pcedu/339/3395651.html
http://jingyan.baidu.com/article/a3aad71adb7bf9b1fb009631.html


#### 0xc00000e9错误：

网上有说引导文件坏掉的，可以通过大白菜修复引导文件，如果仍然不行，那就不用大白菜的装机工具安装系统，而是像文章开头说的方法装，运行windows系统的setup进行安装系统。


#### 建议：

1、用Windows的官网下载的iso运行setup安装，不要下载ghost，集成各种垃圾软件。

2、准备一个驱动精灵，可以离线安装网卡驱动，有了网卡驱动，其他就好办了。

windows每次关机都要关闭所有工作空间，再次开机需要全部重启，真是太麻烦了，或许该换Mac了，o(╯□╰)o！













