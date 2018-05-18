---
title: Git Bash使用ppk
date: 2016-04-11 17:32:58
tags:
     - Git
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

#### 问题描述：
通过git bash连接到服务器需要ssh key，但是我现在只有一个ppk的文件，所以我需要把ppk文件转成ssh key。
<!--more-->
#### 连接原理：
git连接到远程仓库有两种方式：
1：http的方式，http每次使用的时候都需要填写用户名和密码；
2：ssh方式，ssh方式配置完ssh秘钥就不用每次填写用户名密码了（可能需要输入私钥密码）。

ssh秘钥分为公钥和私钥是成对的，公钥放到远程git仓库，私钥放到本地git仓库，ppk文件就是一个私钥，用来给Tortoisegit客户端使用，并且可以转换成ssh key给git bush使用。
#### ppk转ssh key：
需要使用Putty Key Generator工具进行转换，点击load按钮,
![image.png](http://upload-images.jianshu.io/upload_images/800897-5a83ecdafcbf6141.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
加载已经存在的ppk文件，如果这个ppk文件读取需要密码，输入密码后就可以把ppk文件里面的信息读取出来，然后点击Conversions菜单，选择Export OpenSHH key选项
![image.png](http://upload-images.jianshu.io/upload_images/800897-f22bb291f37628b6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
保存成名为id_ras文件(没有扩展名)，这个文件就是ssh 形式的私钥。放到C:/user/用户名/.ssh文件夹下（每个人的文件夹可能不一样）。这就相当于私钥转换成了把git bash需要的格式。
#### git bash配置：
进行git操作发现还要每次输入私钥的密码，如下图所示：
![image.png](http://upload-images.jianshu.io/upload_images/800897-3e8dccaf21fb6fae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
再进行如下操作就可以把私钥的密码配置给git bash，这样以后就不用再输入这个密码了。

```
ssh-agent
ssh-add
```
参考：https://stackoverflow.com/questions/10032461/git-keeps-asking-me-for-my-ssh-key-passphrase

使用msysgit Bash on Windows时，需要执行下面的命令才能成功启动。否则接下来使用ssh-add时会出现`Could not open a connection to your authentication agent`的错误：
```
eval `ssh-agent -s`或eval $(ssh-agent -s)
```
但是Windows git bush上并不起作用，最后我把私钥的密码修改为空，才不用输入密码。
修改秘钥密码：
```
ssh-keygen -p
```
#### 总结：
Git bush私钥每次都要输入密码，其实也是一种安全措施，保护你的电脑被别人操作时，不能随意进行git操作。









