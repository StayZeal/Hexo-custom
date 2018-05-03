---
title: 用lua写Android界面学习笔记
date: 2015-09-10 17:32:58
tags:
     - Android
     - Lua
---
博客地址：http://blog.stayzeal.cn

#### 问题描述：
有时候我们的app可能需要动态的更新一个页面，不只是单纯的内容，有可能布局也要改变，所以就考虑到开发过程中用lua脚本动态加载的Android页面，以便可以不重新发布apk，通过服务端控制就可以做到。
<!--more-->
#### 准备：
AndroLua项目搭建好了用lua开发android的环境，可以直接安装使用，我在使用lua脚本的时候就是在这个项目的基础上进行的。
AndroLua项目地址：[https://github.com/mkottman/AndroLua](https://github.com/mkottman/AndroLua)
#### 原理：

1、lua和java可以互相通信是通过java的jni方式，因为lua可以和C进行通信，java也可以通过jni可C进行通信，所以lua和java进行通信就是通过C来当中介来实现的。

2、lua写Android界面时，lua是不能直接新建Activity的，而是要新建好Activity，然后动态的添加布局

下面我们为一个Activity添加一个Button并绑定OnClick事件

代码：
- lua脚本，放在asset目录下.文件名addbtn.lua：

```
function addBtn(context,layout)

  btn = luajava.newInstance("android.widget.Button",context);
  button_cb = {
    onClick=function(ev)
      print('hello,world')
      Toast = luajava.bindClass('android.widget.Toast')
      Toast:makeText(context, 'hello lua', Toast.LENGTH_SHORT):show()
    end
  }

  buttonProxy = luajava.createProxy("android.view.View$OnClickListener", button_cb)
  btn:setOnClickListener(buttonProxy)

  btn:setText('btn from lua')
  layout:addView(btn)
end
```

- java 代码，用来加载lua脚本并执行：

```
 private void addLuaBtn() {
		mLuaState = LuaStateFactory.newLuaState();
		mLuaState.openLibs();
		try {
			mLuaState.LdoString(readStream(getAssets().open("addbtn.lua")));
			mLuaState.getField(LuaState.LUA_GLOBALSINDEX, "addBtn");
			mLuaState.pushJavaObject(context);// 第一个参数 context
			mLuaState.pushJavaObject(linearLayout);// 第二个参数， Layout
			mLuaState.call(2, 0);// 2个参数，0个返回值
			System.out.println(mLuaState.toString(-1));

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

private String readStream(InputStream openRawResource) {
    StringBuffer sb = new StringBuffer();
    byte[] bytes = new byte[1024];
    try {
           for (int n; (n = openRawResource.read(bytes)) != -1;) {
             sb.append(new String(bytes, 0, n));
           }
         } catch (IOException e) {
           e.printStackTrace();
         }
         System.out.println(sb.toString());
         return sb.toString();
}
```

在Activity的OnCreate()方法中调用`addLuaBtn()`。安装apk就可以看到这个添加的按钮，点击会有Toast 弹窗。

#### 感想：
既然要动态更新Activity的布局，而且又没必要重新的发布新版的的apk以免影响用户体验，用lua脚本就可以实现这个功能，但是这种方式开发起来太复杂，单纯的用java代码来写Android的布局就要比用xml文件的方式复杂的多，再用lua封装一层之后就更加复杂了，而且开发效率很低，所以这种方式只适合更改一些特别简单的布局。为了实现修改更加复杂的布局，可以采用另外一种方案，即动态加载Android的dex文件。这就是另外一种热更新的方案了，还在学习中。
