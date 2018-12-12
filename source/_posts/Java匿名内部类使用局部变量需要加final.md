---
title: Java匿名内部类使用局部变量需要加final
date: 2015-04-10 17:32:58
tags:
     - Java
---
博客地址：http://blog.stayzeal.cn
测试用例：
```
 public class Test2Final {
    int mA = 10;
    public void test() {
        final int a = 0;
        new Thread() {
            @Override
            public void run() {
                int b = a;
                mA = 100;
            }
        }.start();
    }
}

```
<!--more-->
字节码：
```
{
  final int val$a;
    descriptor: I
    flags: ACC_FINAL, ACC_SYNTHETIC

  final Test2Final this$0;
    descriptor: LTest2Final;
    flags: ACC_FINAL, ACC_SYNTHETIC

  Test2Final$1(Test2Final, int); //两个参数：1.外部类的引用2.局部变量a（成员变量mA不在此）
    descriptor: (LTest2Final;I)V
    flags:
    Code:
      stack=2, locals=3, args_size=3
         0: aload_0
         1: aload_1
         2: putfield      #1                  // Field this$0:LTest2Final;
         5: aload_0
         6: iload_2
         7: putfield      #2                  // Field val$a:I
        10: aload_0
        11: invokespecial #3                  // Method java/lang/Thread."<init>":()V
        14: return
      LineNumberTable:
        line 7: 0

  public void run();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=2, args_size=1
         0: aload_0
         1: getfield      #2                  // Field val$a:I
         4: istore_1
         5: aload_0
         6: getfield      #1                  // Field this$0:LTest2Final;
         9: bipush        100
        11: putfield      #4                  // Field Test2Final.mA:I   成员变量赋值
        14: return
      LineNumberTable:
        line 10: 0
        line 11: 5
        line 13: 14
}

```
**局部变量为什么需要加final：**通过字节码我们可以看到匿名内部类使用局部变量是通过**构造函数形参**传进来的。
```
  Test2Final$1(Test2Final, int);
```
如果在匿名内部类中对变量a进行修改，实际上修改的是final int val$a变量，那么test()中的的a的值是不会改变的。而我们写程序的直观感觉是a也发生了改变，所以为了避免这种误解，Java在编译器就进行了检查，避免这种写法。


>**说明：**上面代码中的写法没有加 final，是Java8的语法。只要你在匿名内部类中对a进行修改，会编译出错。效果是一样的。

**成员变量为什么不要final：**从字节码可以看到，成员变量的赋值是通过持有外部类引用实现的。
```
11: putfield      #4                  // Field Test2Final.mA:I 
```
**其他：**
如果成员变量mA是private的呢？
```
private int mA = 10;
```
字节码会多出一个方法：
```
static int access$002(Test2Final, int);
```
而内部类给成员变量赋值的字节码则变成：
```
11: invokestatic  #4                  // Method Test2Final.access$002:(LTest2Final;I)I
```
这也是内部类可以访问外部类private变量的原因。
