---
title: Android FLAG_ACTIVITY_NEW_TASK一些使用细节
date: 2018-10-10 21:32:58
tags:
     - Android
     - 启动模式
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)
<!--more-->
#### 一、**FLAG_ACTIVITY_NEW_TASK**文档：
>If set, this activity will become the start of a new task on this history stack. A task (from the activity that started it to the next task activity) defines an atomic group of activities that the user can move to. Tasks can be moved to the foreground and background; all of the activities inside of a particular task always remain in the same order. See Tasks and Back Stack for more information about tasks.
This flag is generally used by activities that want to present a "launcher" style behavior: they give the user a list of separate things that can be done, which otherwise run completely independently of the activity launching them.
When using this flag, **if a task is already running for the activity you are now starting**, then a new activity will not be started; instead, the current task will simply be brought to the front of the screen with the state it was last in. See FLAG_ACTIVITY_MULTIPLE_TASK for a flag to disable this behavior.
This flag can not be used when the caller is requesting a result from the activity being launched.

大概意思：**FLAG_ACTIVITY_NEW_TASK**
1、如果task不存会启动新的task，如果存在则使用已存在的task，则把task按照原来的顺序给移动到前台和后台。
2、如果task存在要启动的Activity，则不会启动新的Activity。
操作一：
1、桌面图标->A->B->C
2、广播接收器启动A
**Task中顺序：ABCA**，因为从桌面图标启动的A和广播接收器启动A不是同一个实例。
操作二：
1、广播接收器->A->B->C
2、广播接收器启动A
**Task中顺序：ABC**，A都是从广播接收器启动，是同一个实例。
#### 二、和**FLAG_ACTIVITY_CLEAR_TOP**同时使用：
我们看一下，设置了**"singleTask"**启动模式的Activity的特点：
>1. 设置了"singleTask"启动模式的Activity，它在启动的时候，会先在系统中查找属性值affinity等于它的属性值taskAffinity的任务存在；如果存在这样的任务，它就会在这个任务中启动，否则就会在新任务中启动。因此，如果我们想要设置了"singleTask"启动模式的Activity在新的任务中启动，就要为它设置一个独立的taskAffinity
属性值。
>2. 如果设置了"singleTask"启动模式的Activity不是在新的任务中启动时，它会在已有的任务中查看是否已经存在相应的Activity实例，如果存在，就会把位于这个Activity实例上面的Activity全部结束掉，即最终这个Activity实例会位于任务的堆栈顶端中。

以上来自：https://blog.csdn.net/Luoshengyang/article/details/6714543

所以FLAG_ACTIVITY_NEW_TASK和FLAG_ACTIVITY_NEW_TASK就相当于singleTask。
#### 三、和**FLAG_ACTIVITY_CLEAR_TASK**同时使用：
每次会清空Task，然后要启动的Activity变成Task的root。















