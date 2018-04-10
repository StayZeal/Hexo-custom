---
title: Java Socket通信BufferedReader.readLine()阻塞问题
date: 2018-04-02 17:32:58
tags:
     - Java
     - BufferedReader
     - Socket 
---
博客地址：http://blog.stayzeal.cn

# 问题描述：
- [Java Scoket实现Http服务器处理Post请求-称为S](http://blog.stayzeal.cn/2018/03/29/Java-Scoket%E5%AE%9E%E7%8E%B0Http%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%A4%84%E7%90%86Post%E8%AF%B7%E6%B1%82/)
- [Java Socket实现发送Http请求-称为mC](http://blog.stayzeal.cn/2018/04/01/Java-Socket%E5%AE%9E%E7%8E%B0%E5%8F%91%E9%80%81Http%E8%AF%B7%E6%B1%82/)
<!--more-->

**Server端：**
```  
while ((str = buff.readLine())!=null) {
                System.out.println("---");
                System.out.println(str);
 }
```
**Client端：**
```
out.write("我是客户端\r\n")；//没有\r\n服务端会阻塞
out.flush();
```
以上readline()方法在没有读到\r\n换行符时，readline()会一直阻塞，但是即使有\r\n，server端的while循环还是阻塞在readline()，因为readline()不知道BufferedReader什么时候结束（这和读文件是不同的）。

但是同样是的服务器S，自己的客户端mC会造成阻塞，但是用Okhttp3请求就不会阻塞，经过研究发现是Okhttp3的流及时关闭，所以通过关闭流可让readline()知道什么时候流结束了。

那么到底怎么关闭流呢？直接在客户端：
```
out.flush();
out.closed();//但是再也收不到服务端的返回结果（报如下异常）
//err
java.net.SocketException: Socket is closed
```
PS：以上关闭输出流，Socket为什么会关闭，这点还不是很清楚。

# 解决方案：
```
//   当调用Socket.shutdownInput( )后，还能够往该套接字中写数据（执行OutputStream.write( )）；
//   当调用Socket.shutdownOutput( )后，还能够往该套接字中读数据（执行InputStream.read( )）；
Socket.shutdownInput()
Socket.shutdownOutput()
```
分别关闭Socket的输入输出流。

**有人说read()方法是不会阻塞的，但是read()方法也会阻塞，道理相同，就是都不知道流什么时候结束。**
# 总结：

readline()阻塞原因有两种：
- 没有\r\n换行符
- 不知道流什么时候结束

解决分别通过加换行符和关闭流。所以在进行Socket通信的时候一定要注意readline()和read()阻塞的问题。
# 附言
在写开头两篇博客的时候发现了readline()的阻塞问题，但是搜索网上发现写法都比较类似，没有相关的解决方案。所以就打算使用`while ((str = buff.readLine())!=null&&str.length>0)`来解决问题，但是用Okhttp3却没有这个问题。这让我很费解，通过上网搜索，也知道可以通过关闭流来解决问题，但是关闭了流之后，又报异常。无奈只好Debug调试Okhttp3的代码，幸好之前对Okhttp3和Okio源码有点了解，结果发现Okhttp3就是通过关闭流来解决的。
```
//public final class CallServerInterceptor implements Interceptor
        Sink requestBodyOut = httpCodec.createRequestBody(request, request.body().contentLength());
        BufferedSink bufferedRequestBody = Okio.buffer(requestBodyOut);
        request.body().writeTo(bufferedRequestBody);
        bufferedRequestBody.close();
```
那么只好硬着头皮搜索`java socket outputStream 关闭`，结果这次是正确的打开方式了。网上千遍一律的博客还是有用的，最起码大家都这么说，说明是正确的，根据你获取的信息，继续寻找你的方向才是问题的解决之道。

**参考：**
https://blog.csdn.net/dabing69221/article/details/17351881
https://blog.csdn.net/swingline/article/details/5357581