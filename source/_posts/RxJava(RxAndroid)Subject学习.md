---
title: RxJava(RxAndroid)Subject学习
date: 2016-05-12 17:32:58
tags:
       - RxJava
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

本文主要内容出自：
http://reactivex.io/documentation/subject.html
Subject是一种bridge和proxy，它既是Observable又是Observer。从Subject类定义就可以看出这一点，如下：
<!--more-->
```
public abstract class Subject<T, R> extends Observable<R> implements Observer<T>{...}
```

#### Subject分类：
- AsyncSubject
- BehaviorSubject
- PublishSubject
- ReplaySubject

AsyncSubject：只会响应subject.subscribe(observer)之后最近发送的事件，即只会接收一个事件；如果发生错误，则只接受错误事件。
BehaviorSubject：只会响应subject.subscribe(observer)调用时之前最近的一个事件和之后Observable发送的所有事件；如果发生错误，则只接受错误事件。

 例子:
```java
 // 接收所有事件.
  BehaviorSubject<Object> subject = BehaviorSubject.create("default");

  subject.subscribe(observer);
  subject.onNext("one");
  subject.onNext("two");
  subject.onNext("three");


  // 只接收事件 "one", "two" and "three" events, 而没有事件 "zero"
  BehaviorSubject<Object> subject = BehaviorSubject.create("default");
  subject.onNext("zero");
  subject.onNext("one");

  subject.subscribe(observer);
  subject.onNext("two");
  subject.onNext("three");


  // 只接收onCompleted事件
  BehaviorSubject<Object> subject = BehaviorSubject.create("default");
  subject.onNext("zero");
  subject.onNext("one");
  subject.onCompleted();
  subject.subscribe(observer);

  // 只接收 onError事件
  BehaviorSubject<Object> subject = BehaviorSubject.create("default");
  subject.onNext("zero");
  subject.onNext("one");
  subject.onError(new RuntimeException("error"));
  subject.subscribe(observer);
  ```
PublishSubject：响应subject.subscribe(observer)调用之后的所有事件;如果发生错误，则只接受错误事件。
ReplaySubject：则会接收Observable发出的所有事件。