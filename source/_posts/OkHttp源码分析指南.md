---
title: OkHttp源码分析指南
date: 2018-04-23 17:32:58
tags:
     - OkHttp
     - Android
---
博客地址：http://blog.stayzeal.cn

要分析OkHttp源码需要知道两点：
- OkHttp做了什么工作
- OkHttp怎么做的这些工作
<!--more-->
##### 一、OkHttp做了什么工作
它从Socket层面实现四种协议，其中包括：
- Http 1.1协议
- Http 2.0协议
- Https协议
- WebSocket协议

而实现后面三种协议都是在Http 1.1协议的基础上进行实现，我们先主要分析一下Http1.1协议。通过文章[Java Socket实现发送Http请求]()我们知道实现Http协议需要下面几步：
1、获取Socket连接：
```
socket = new Socket(IP, PORT);
```
2、获取输入输出流：
```
outputStreamWriter = new OutputStreamWriter(socket.getOutputStream());
inputStreamReader= new InputStreamReader(socket.getInputStream());
```
3、把数据封装成Http格式
```
outputStreamWriter.write("GET " + path + " HTTP/1.1\r\n");
outputStreamWriter.write("Host: " + IP + "\r\n");
outputStreamWriter.write("\r\n");
```
4、发送数据：
```
outputStreamWriter.flush();
socket.shutdownOutput();
```
5、接收数据：
```
bufferedReader = new BufferedReader(inputStreamReader);
String line = null;
while ((line = bufferedReader.readLine()) != null) {
          System.out.println(line);
}
```
6、关闭Socket和输入输出流：
```
socket.close();
outputStreamWriter.close();
bufferedReader.close();
```
总结一下：以上`Socket`建立连接，发送数据，接收数据，关闭`Socket`的连接。OkHttp就是对上述过程进行了封装优化，功能进行了丰富（包括复用连接，Gzip，Cookie，Cache，Https，Http 2.0，WebScoket，断线重连，超时机制等）

##### 二、OkHttp是怎么做的：
1、获取Socket连接：
>OkHttp并不是直接新建Socket连接，而是先从连接池中获取，如果连接池中没有才new出一个新的Socket连接，并放入连接池方便下次使用。

2、获取输入输出流：
>通过Okio对输入输出流进行封装。

3、把数据封装成Http格式：

> 通过`BridgeInterceptor类`对Header和Body进行封装。

4、发送数据
> `HttpCodec类`的`finishRequest()`方法实现。

5、接收数据
 ```
Response response = responseBuilder
        .request(request)
        .handshake(streamAllocation.connection().handshake())
        .sentRequestAtMillis(sentRequestMillis)
        .receivedResponseAtMillis(System.currentTimeMillis())
        .build();
```

6、关闭Socket和输入输出流
>使用完并不关闭Socket连接，而是放在连接池中方便下次Http请求使用。

##### 下面我们看一下一个Http 1.1 请求的代码执行过程，为了方便我们先看同步请求：

发起同步请求的代码：
```
OkHttpClient client = new OkHttpClient();
Request request = new Request.Builder()
            .url("https://api.github.com/repos/square/okhttp/issues")
            .header("User-Agent", "OkHttp Headers.java")
            .addHeader("Accept", "application/json; q=0.5")
            .addHeader("Accept", "application/vnd.github.v3+json")
            .build();
 Response response = client.newCall(request).execute();// 同步请求
```
`newCall(request)`方法会把一个`Request`对象封装成`RealCall`对象，我们接着看`RealCall`的`execute()`方法：
```
 ...
  //主要代码，result 通过这里获取
  Response result = getResponseWithInterceptorChain();
...
```
所以主要处理逻辑在`getResponseWithInterceptorChain()`，这里的代码使用了**责任链设计模式**来对`Request`和`Response`进行处理：
```
Response getResponseWithInterceptorChain() throws IOException {
    // Build a full stack of interceptors.
    List<Interceptor> interceptors = new ArrayList<>();
    interceptors.addAll(client.interceptors());//1
    interceptors.add(retryAndFollowUpInterceptor);//2
    interceptors.add(new BridgeInterceptor(client.cookieJar()));//3
    interceptors.add(new CacheInterceptor(client.internalCache()));//4
    interceptors.add(new ConnectInterceptor(client));//5
    if (!forWebSocket) {
      interceptors.addAll(client.networkInterceptors());//6
    }
    interceptors.add(new CallServerInterceptor(forWebSocket));//7

    Interceptor.Chain chain = new RealInterceptorChain(
        interceptors, null, null, null, 0, originalRequest);
    return chain.proceed(originalRequest);
  }
```
代码1`client.interceptors()`是在构造OkHttpClient时传入的，我们前面的代码`OkHttpClient client = new OkHttpClient();`并没有设置，所以这一行暂时不起起作用。
代码2我们看一下retryAndFollowUpInterceptor实在RealCall的构造函数被赋值的：
```
RealCall(OkHttpClient client, Request originalRequest, boolean forWebSocket) {
   ...
    this.retryAndFollowUpInterceptor = new RetryAndFollowUpInterceptor(client, forWebSocket);

    // TODO(jwilson): this is unsafe publication and not threadsafe.
    this.eventListener = eventListenerFactory.create(this);
  }
```
代码3、4、5、6、7也是把不同的`Interceptor`放入到`interceptors`中，最后传入`Interceptor.Chain`的构造方法，然后调用`chain.proceed(originalRequest)`。通过Debug我们发现接下来会依次进入代码1、2、3、4、5、6、7中的`public Response intercept(Chain chain)方法`。
关于每个`Interceptor`的作用请查看[拆轮子系列：拆 OkHttp](https://blog.piasy.com/2016/07/11/Understand-OkHttp/)。

附加几个类的说明：
- Connection：对应`Socket`连接，放入到`ConnectionPool`中。
- HttpCodec：对应`InputStream`的`read`操作和`OutputStream`的`write`操作。
- StreamAllocation：包含`ConnectionPool`和`HttpCodec`。