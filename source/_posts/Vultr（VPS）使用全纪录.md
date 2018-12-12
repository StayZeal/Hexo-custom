---
title: Vultr（VPS）使用全纪录
date: 2016-02-11 17:32:58
tags:
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

**服务端配置：**
1、选择需要的配置，系统，初始化服务器
<!--more-->
2、在部署任何服务之前，先ping一下服务器的IP地址，如果不能Ping通，删掉服务器，新建一个
3、修改root密码，Vultr分配的密码比较难记，改成自己的密码比较方便。首先用默认密码登陆，然后执行`passwd`命令，根据提示设置新的密码。
4、使用Putty连接Vultr,使用linux更方便，具体使用比较简单，可以自行百度。
或者`ssh root@ipaddresss`
5.安装node.js,[详细文档](https://nodejs.org/en/download/package-manager/)
Ubuntu 命令
```
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
```
6、安装ShadowSock server，[详细文档](https://shadowsocks.org/en/download/servers.html)
Debian/Ubuntu服务器安装，启动和查看
```
安装
sudo apt update
sudo apt install shadowsocks-libev
```

```
启动服务
service shadowsocks-libev restart
```
在/etc/shadowsocks-libev/文件夹下面可以看到配置文件：
**IP地址，密码，加密方式**都需要进行配置。
```
查看
cat config.json
修改
vim config.json
```
```
查看进程
netstat -lnp | grep ss-server
```
[参考文章](https://cokebar.info/archives/767)
**客户端配置：**
把服务器地址，端口，密码和加密方式设置好就可上网了。







