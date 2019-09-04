---
title: Java反射
date: 2017-04-10 17:32:58
tags:
     - Java
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

<!--more-->
类
===

`public static Class<?> forName(String className)`
`public static Class<?> forName(String name, boolean initialize,ClassLoader loader)`

- 内部类(包括静态内部类)
1、`Outer$Inner`（通过反编译可以看到内部类是这种表达形式）
2、`public native Class<?>[] getDeclaredClasses()`返回所有的内部类，但是不包含继承的类。

- 父类
1、`public Class<?>[] getInterfaces()`获取所有实现的接口，接口顺序和extends顺序一致
2、`public Class<? super T> getSuperclass()` 获取父类，如果是数组则返回Object对象；如果是Object，基础类型或者void，返回null；

对象
===
首先获取类：`Class clz = Activity.class`
然后实例化：`clz.newInstance()`
- 内部类对象
同上
- 通过非静态内部类拿外部类的引用
反射该属性：this$0

方法Method
===
- private protect public override static
`getMethod()`获取所有public的方法，包括父类；
`getDeclaredMethod()`获取所有的方法，但是不包括父类方法
所以无法直接获取父类的非public方法。可以通过现获取父类，然后调用`getDeclaredMethod()`
- 方法调用
`public native Object invoke(Object obj, Object... args)`，obj代表对象，args代表方法参数。

属性Field
===
- private protect public override static
`getField()`获取所有public的属性，包括父类
`getDeclaredField()`获取所有的属性，包括private，不包括父类
所以无法直接获取父类的非public属性。可以通过现获取父类，然后调用`getDeclaredField()`
- 获取属性值
`public native Object get(Object obj)`
如果是private需要调用`setAccessible(true)`
