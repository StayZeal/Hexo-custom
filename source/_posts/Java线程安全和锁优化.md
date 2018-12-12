---
title: Java线程安全和锁优化
date: 2018-03-20 17:32:58
tags:
     - Java
---
博客地址：http://blog.stayzeal.cn

### **线程安全的实现有三种方法：**
#### 1、互斥同步（阻塞同步）：悲观锁
<!--more-->
- Synchronized：monitorenter，monitorexit实现。
```
monitorenter：每个对象有一个监视器锁（monitor）。当monitor被占用时就会处于锁定状态，线程执行monitorenter指令时尝试获取monitor的所有权，过程如下：
1、如果monitor的进入数为0，则该线程进入monitor，然后将进入数设置为1，该线程即为monitor的所有者。
2、如果线程已经占有该monitor，只是重新进入，则进入monitor的进入数加1.
3.如果其他线程已经占用了monitor，则该线程进入阻塞状态，直到monitor的进入数为0，再重新尝试获取monitor的所有权。

monitorexit：执行monitorexit的线程必须是objectref所对应的monitor的所有者。
指令执行时，monitor的进入数减1，如果减1后进入数为0，那线程退出monitor，不再是这个monitor的所有者。其他被这个monitor阻塞的线程可以尝试去获取这个 monitor 的所有权。 
```
- ReentrantLock：
1、等待可中断；
2、可实现公平锁，Synchronized是非公平锁（锁被释放是，任何一个等待的线程都有机会获得锁）。
3、锁可以绑定多个条件

都具有可重入性，两者在Java1.6开始性能无差异。

#### 2、非阻塞同步：
乐观锁，使用CAS，JUC库中的Atomic类实现，底层通过sun.misc.Unsafe实现(高版本jdk可能不一样).
```
CAS可能有ABA的逻辑漏洞
```
### 3、无同步方案：
- 可重入代码：一个方法的返回结果是可以预测的，只要输入相同的数据，都能放回相同的结果。
- 线程本地存储：ThreadLocal

## **锁优化**
#### 1、
- 自旋锁：等待锁释放但是不释放cpu。
- 自适应自旋：虚拟机实现

#### 2、锁消除
虚拟机计时编译器在运行时自动处理。
#### 3、锁粗化
扩大锁的范围
4、轻量级锁
5、偏向锁

## 内存模型三个特性：
- 原子性：Synchronized
- 可见性：Synchronized，Volatile，Final
- 有序性：Synchronized，Volatile

## happen-before原则：
无须任何同步措施，就能保证程序的执行顺序。有8中规则，如果不在这八种规则中，则虚拟机可以随意指令排序，没有顺序性保证。
 
## Volatile作用：
- 可见性：当一个线程修改了这个变量的值，新值对于其他线程来说是立即可得知的。
- 禁止指令重排：添加内存屏障的方式实现