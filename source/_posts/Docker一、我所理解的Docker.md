---
title: Docker一、我所理解的Docker
date: 2018-02-8 17:32:58
tags:
     - server
---
博客地址：http://blog.stayzeal.cn

Docker类似于装了操作系统的虚拟机，但是又比虚拟机占用的资源要少。在这个虚拟机中，你可以部署好你的开发环境，比如，Java，Node.js，Python的各种依赖包，然后在虚拟机中开发，测试，和 上线。这个部署好的虚拟机可以打包成image（镜像），有点像操作的备份的ghost包。然后在需要的机器上运行你的image，这样在不同的机器上就不用重复配置开发环境了，运行同一image的机器可以有不同的操作系统，比如，Windows，Mac，Linux。
`（平时在开发过程中，你在公司和家里有两台电脑，如果想要开发Java，可能需要配置两套开发环境，下载各种依赖包，特别是有些依赖包下载速度又是那么慢（虽然可以配置国内镜像），真是麻烦，而且同样的东西要配置好几遍。通过Docker的image就可以来解决这个问题）`
部署好的image可以上传到Docker的官网，这样在不同的机器上你都可以通过Docker下载，别人也可下载你的image，你也可以下载别人集成各种环境的image，就像Github一样。当然也可以进行私有管理。image还是可设置Tag，即版本。

Docker在分布式系统中使用较多，使用过程中分为三个层次：

- Container ：每一个运行的image，称为container。就像类和对象的关系一样。

- Service：在分布式系统中，系统由不同的Service组成，比如视频分享网站的文件存储、视频转码、前端等，就是不同的Service。  在Docker中，Service可能根据需要会包含好几个Container（好像分负载均衡有关，我不是太了解）。每一个Container称为Task，并且每个Task都有Id。

- Stack：由多个Service组成，可以理解为整个系统了。

小结：Stack包含Service，Service包含Container。

Swarm：运行着Docker的服务器集群。每一个加入集群的机器(包括真实的或者虚拟的)称为Node。并通过Swarm Manager管理，使用Swarm需要切换到`swarm mode`。这里面的还有一个Worker的概念，其实就是Node（不知道为什么有两个概念）。

Docker 安装，分为四种：
1、Linux
2、Win10
3、Mac
4、Win7（不推荐，没有前面三种方便，Win10的powershell真的强大，为此我又重装了系统）
安装方式比较简单可去官网查看https://www.docker.com/

Docker的文档写的很好，更多请看：https://docs.docker.com/get-started/