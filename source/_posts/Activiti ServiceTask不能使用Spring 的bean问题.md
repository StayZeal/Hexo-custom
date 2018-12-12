---
title: Activiti ServiceTask不能使用Spring 的bean问题
date: 2014-10-12 17:32:58
tags:
       - Activiti
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

参考网址：[https://groups.google.com/forum/#!topic/camunda-bpm-users/M7K3KXiEHaA](https://groups.google.com/forum/#!topic/camunda-bpm-users/M7K3KXiEHaA)

参考网址：[https://groups.google.com/forum/#!topic/camunda-bpm-users/M7K3KXiEHaA](https://groups.google.com/forum/#!topic/camunda-bpm-users/M7K3KXiEHaA)

#### 问题描述：

`java`类实现` activiti`提供的`JavaDelegate`接口时，获取不到`spring`给我们加载的bean类，会报` java.lang.NullPointerException`；
<!--more-->
#### 解决如下：

当使用 `activiti:class` 把一个`class`指定给`ServiceTask`时,需要实现`JavaDelegate`接口，`activiti`引擎将会在内部用`Class.newInstance(..)`方法创建一个该类的对象，这个对象并不`spring`容器管理，所以无法获取`spring`容器给我们生成的`bean`；

所以我们只能换一种方式来实现 `serviceTask`的功能，`serviceTask`还有两个属性：`activiti:expression`和`activiti:delegateExpression`

`activiti:expression="${retrieveCustomerServiceTask.retrieveCustomer(execution,customerId)}"`：会调用`retrieveCustomerServiceTask`的 `retrieveCustomer(execution,customerId)`方法，参数`execution`和`JavaDelagate` 中的方法`execute(DelegateExecution execution )`参数一样，参数`customerId`是自定义的。在这个方法中就可以使用`spring`为我们提供的`bean`了。（亲测好用）

顺便提一下` activiti:delegateExpression="${customerServiceTask}" ` 将会执行实现了`JavaDelegate`的类的`execute(DelegateExecution execution )`方法。（未亲测）
