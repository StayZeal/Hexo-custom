---
title: 如何阅读RxJava2源码，以及阅读笔记
date: 2018-04-12 17:32:58
tags:
       - RxJava2
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

宏观了解，RxJava优点：

- 可以方便的进行线程切换
- 有功能强大的操作符可以使用
<!--more-->

设计模式：

- 观察者模式
- 装饰者模式：Observable和Observer的处理经过层层封装。
- 单例模式

想知道实际阅读具体调用哪个类：通过Debug。

带着问题去看：

- RxJava怎样实现观察者模式
- RxJava怎样实现线程调度
- RxJava怎样实现Map、FlapMap等操作符

**最重要的一点就是一定要亲自阅读源码！**

**以下是笔记：**
Map：通过ObservableMap、MapObserver的一个简单变换实现。
FlapMap：通过把每个结果封装成Observable，然后放入Queue来发射每个事件来实现。
线程调度：Scheduler/Worker机制来实现。Scheduler调用Woker的schedule（）来把任务放入线程池中执行（Schedule对Woker进行一些封装）。多线程通过线程池来实现，处理结果通过Future来传递。Observable和Observer在不同线程之间传递是通过AtomicReference来实现。
IO线程和计算线程Schedule的区别：线程池的类型不一样，IO线程比较少（只有一个），而计算线程可以有多个。
AndroidScheduler：通过Handler来实现。