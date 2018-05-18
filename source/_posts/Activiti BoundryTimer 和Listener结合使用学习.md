---
title: Activiti BoundryTimer 和Listener结合使用学习
date: 2014-10-11 17:32:58
tags:
     - Java
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

#### 一、问题描述：

在`task`上定义一个边界定时器（`boundaryTimer`），7天后定时结束，然后进行根据7天后的是时间和一个特定的时间进行比较，添加一个网关进行判断，那么怎么在定时器结束时进行判断呢？
       <!--more-->
#### 二、解决方法：

在`boundaryTimer`添加`listener`，并绑定到`event`的`end`事件上。这样在边界定时器结束时，就会执行绑定listener的实践，绑定监听器有这几种方式：
- `javaclass`： 一个Java class ，需要实现特定的接口。                                                 
- `execution`：如`${testListener.myFunc(execution,myVar)} testListener `是一个java对象，`myFunc(execution,myVar)`是成员方法，`execution`类型是`DelegateExecution`，`myVar`是一个流程变量，可以通过设置流程变量的方法进行设置。
- `delegateExecution`： 如`${testListener1.startDate}`，使用`execution`的好处是，可以自己定义方法，设置需要的参数。

#### 三、代码演示：

```
@Service("testListener")
public class TestListener{
	 @Resource("runtimeService")
	 RuntimeService runtimeService;
     public myFunc(DeledateExecution execution,Date myVar){
    	 String executionId = execution.getId();
    	 Date date = getDate();//获取指定的日期
    	 Map<String , Object> variable = new HashMap<String , Object>();
    	 if(date.getTime()>myVar.getTime()){
    		 variable.put("processVar", "1"); //GateWay流程变量
    	 }else{
    		 variable.put("processVar", "2"); //GateWay流程变量
    	 }
    	 runtimeSerice.setVariables(executionId,variable);
     }
}
```
