---
title: Android 多线程使用总结
date: 2018-04-10 17:32:58
tags:
     - Android
     - 多线程
---
博客地址：http://blog.stayzeal.cn

Android主线程（UI线程）不能进行耗时操作，所以耗时操作要放到其他线程中，方法有以下几种：
- Thread/Runbale方式
- AsyncTask方式
- HandlerThread方式
- 线程池方式
- RxJava方式
<!--more-->

第一种，继承Thread或者实现Runable接口，通过`new Thread().start()`方法实现，方法比较简单。

第二种，继承AsyncTask，通过`new AsyncTask().excute()`实现，方便进行UI操作。
AsyncTask内部也是使用线程池来创建线程。

第三种，实例化HandlerThread()类：
```
HandlerThread handlerThread = new HandlerThread ("test-1");
handlerThread.start();

Handler handler = new Handler(handlerThread.getLooper()) ;
       handler.post(new Runnable() {
           @Override
           public void run() {
               //do something
           }
       });
```
关于使用AsyncTask和HandlerThread的好处：
>我们一般把一个耗时的操作看作是一个后台任务，并且放在一个子线程中执行。在这些后台任务中，有的是一次性的，即执行了一次之后就不再需要了;而有的是需要不定期执行的，即条件满足时就执行，条件不满足时就不执行。<br>
对于不定期的后台任务来说，它们有两种执行方式。第一种方式是每当条件满足时，就创建个子线程来执行一个不定期的后台任务;而当这个不定期的任务执行完成之后，新创建的子线程就随之退出。第二种方式是创建一个具有消息循环的子线程，每当条件满足时，就将一个不定 期的后台任务封装成一个消息发送到这个子线程的消息队列中去执行;而当条件不满足时，这个子线程就会因为它的消息队列为空而进人睡眠等待状态。虽然第一种方式创建的子线程不需要具有消息循环，但是不断地创建和销毁子线程是有代价的，因此，我们更倾向于采用第二种方式来执行那些不定期的后台任务。从这个角度来看，我们就希望Android应用程序子线程像主线程一样具有消息循环。<br>
                                                                     《Android系统源代码情景分析》

第四种，线程池的使用相关的知识了，这里不再赘述，请自行学习。
第五种，RxJava内部其实也是使用线程池，但是切换线程简单粗暴，也是我目前在项目重要使用的方式。

**问题**
HandlerThread和RxJava哪个性能更好呢？或者说两者分别适合什么样的场景？