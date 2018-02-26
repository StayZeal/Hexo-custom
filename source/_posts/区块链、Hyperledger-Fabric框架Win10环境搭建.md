---
title: 区块链、Hyperledger-Fabric框架Win10环境搭建
date: 2018-02-11 17:32:58
tags:
---
博客地址：http://blog.stayzeal.cn
上一篇： [区块链、Hyperledger-Fabric框架概览](http://blog.stayzeal.cn/2018/02/11/%E5%8C%BA%E5%9D%97%E9%93%BE%E3%80%81Hyperledger-Fabric%E6%A1%86%E6%9E%B6%E6%A6%82%E8%A7%88/)
说明：
 ```
本文源于官网，不同的叙述方式，包括踩坑。
为什么用Win10：
1、Docker支持Win10比Win7更友好
2、PowerShell功能强大
3、没有Mac，Linux没装
需要：Docker，Node.js，Git bash，Go环境
```
从git仓库中下载官方实例源码：
```
git clone -b master https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
```

打开fabcar文件夹：
```
cd fabric-samples/fabcar  
```
执行如下脚本（还是先别执行，往下看吧）：
```
./startFabric.sh
```
脚本应该是执行失败的，是因为环境没有搭建，下面我们需要搭建运行环境了：
-------------
- 原理：Fabric环境通过Docker封装，所以需要从从Docker下载Fabric的相关镜像。
- 步骤：
1 、安装Docker
2、下载Docker image
3、安装Node.js
4、安装grpc
安装Docker之后：
```
//git bash中执行
curl -sSL https://goo.gl/6wtTN5 | bash -s 1.1.0-alpha
```
如果失败，打开连接[https://github.com/hyperledger/fabric/blob/master/scripts/bootstrap.sh](https://github.com/hyperledger/fabric/blob/master/scripts/bootstrap.sh)
保存到本地`bootstrap.sh`，通过git bash执行脚本，下载镜像（过程很慢，可以配置Docker使用阿里的镜像，可能还是很慢）

下载完之后：执行`docker image ls `，TAG是版本号：
![image-1.png](http://upload-images.jianshu.io/upload_images/800897-37c37af8f250405b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在执行脚本之前，还需要通过npm 安装包，所以需要安装Node.js(6.9版本以上，不支持7.x，可以安装最新的8.x)：
安装Node.js之后，在fabcar目录中执行：
```
npm intall
```
如果grpc安装失败，删除 `C:\Users\<username>\.node-gyp\<node_version>\include\node\openssl `重新执行 `npm install`，参考https://www.npmjs.com/package/grpc


执行`./startFabric.sh`脚本可能出现：
- 1：
```
//err
manifest for hyperledger/fabric-orderer:latest not found
```
打开` fabric-samples/base-network`的`docker-compose.yml`文件中所有image的版本为图image-1中所下载的版本，可以参考https://www.jianshu.com/p/f5a602f61ac1

- 2：grpc下载不正确，删除fabcar/node-module/下的grpc，从新执行npm install：
![image.png](http://upload-images.jianshu.io/upload_images/800897-aca33cf9ad7646ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 3
![image.png](http://upload-images.jianshu.io/upload_images/800897-adafecd9f27eca20.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

删掉grpc，在`fabcar/package.json`修改grpc版本为`1.9.0`(写文章时的最新版本)，重新下载。
执行`./startFabric.sh`，输出如下，代表启动成功（截图不完整）：
![image.png](http://upload-images.jianshu.io/upload_images/800897-b9189a55386b0854.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

总结：坑还是挺多的......