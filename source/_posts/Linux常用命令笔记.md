---
title: Linux常用命令笔记
date: 2015-04-11 17:32:58
tags:
     - Linux
     - Shell
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

1、`cp -r  完整路径文件名（from）完整路径文件名（to）`；

2、`mv A B` 剪切A 到B，可用于重命名；

3、`ps aux `查看系统进程信息；`ps aux|grep A` 查看进程A的信息；`kill -9 A `杀掉ID为A的进程；

4、`vim B` 编辑文件B；然后 i 表示Inert ；`shirft + : + p`(没有修改的情况下退出文件)/`p!`(不保存修改，强制退出)/`wp`(保存修改并退出)；向下箭头显示文件全部内容 ；

5、`cd /A `打开文件夹A; `cd` 回到根目录；`cd ../` 返回上一层目录;

6、`tab键` 补全文件名；

7、`./b.sh `运行名为b.sh的shell脚本；

8、`upzip` 解压zip文件；

9、`clear` 清屏；

10、`sudo su` 切换到root；

11、`chmod 参数 文件名 ` 修改文件权限；参数共10个，用2进制表示；常用chmod  755 data 把data全部权限给用户；

        你可以在linux终端先输入ls -al,可以看到如:
        -rwx-r--r-- (一共10个参数)
        第一个跟参数跟chmod无关,先不管.
        2-4参数:属于user
        5-7参数:属于group
        8-10参数:属于others
        接下来就简单了:r==>可读 w==>可写 x==>可执行
               r=4      w=2      x=1
        所以755代表 rwxr-xr-x。

12、`ll/ls -l` 列表显示文件内容；

13、`rm -rf A` 强制删除文件A(慎用)，删除数据没有任何提示，且不易找回。`rm -rf * `强制删除文件中所有内容；

14、`top` 查看cup 内存等使用情况；







