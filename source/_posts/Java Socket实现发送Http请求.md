---
title: Java Socket实现发送Http请求
date: 2018-04-01 17:32:58
tags:
     - Java
     - Socket
     - Post
---
博客地址：http://blog.stayzeal.cn


使用Java Socket发送Http请求，就是把数据封装Http协议的格式。Get请求格式比较简单，这里省略。
<!--more-->
Post请求格式如下：
```
Header:
POST hello HTTP/1.1
Host: 127.0.0.1
Content-Length: 30
Content-Type: application/x-www-form-urlencoded

name=%E5%B0%8F%E6%98%8E&age=18
```

 
```
public class ClientDemo {

	public static final int PORT = 80;
	public static final String IP = "127.0.0.1";

	public static void main(String[] args) {

		ClientDemo clientDemo = new ClientDemo();
		try {
			Map<String, String> map = new HashMap<>();
			map.put("name", "小明");
			map.put("age", "18");
			clientDemo.post("hello", map);
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void get(String path) throws UnknownHostException, IOException {
		Socket socket = null;
		OutputStreamWriter outputStreamWriter = null;
		BufferedReader bufferedReader = null;

		socket = new Socket(IP, PORT);
		outputStreamWriter = new OutputStreamWriter(socket.getOutputStream());

		outputStreamWriter.write("GET " + path + " HTTP/1.1\r\n");
		outputStreamWriter.write("Host: " + IP + "\r\n");
		outputStreamWriter.write("\r\n");
		outputStreamWriter.flush();

		// socket.shutdownOutput();

		bufferedReader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		String line = null;
		while ((line = bufferedReader.readLine()) != null) {
			System.out.println(line);
		}

		socket.close();
		outputStreamWriter.close();
		bufferedReader.close();
	}

	public void post(String path, Map<String, String> params) throws IOException {

		Socket socket;
		OutputStreamWriter outputStreamWriter;
		BufferedReader bufferedReader;

		socket = new Socket(IP, PORT);

		StringBuilder data = new StringBuilder();

		boolean first = true;

		for (Entry<String, String> entry : params.entrySet()) {
			if (!first) {
				data.append("&");
			}
			first = false;
			data.append(entry.getKey());
			data.append("=");
			data.append(URLEncoder.encode(entry.getValue(), "utf-8"));

		}

		outputStreamWriter = new OutputStreamWriter(socket.getOutputStream());
         //header要有/r/n换行符
		outputStreamWriter.write("POST " + path + " HTTP/1.1\r\n");
		outputStreamWriter.write("Host: " + IP + "\r\n");
		outputStreamWriter.write("Content-Length: " + data.toString().length() + "\r\n");
		outputStreamWriter.write("Content-Type: application/x-www-form-urlencoded\r\n");
		outputStreamWriter.write("\r\n");// post参数和header之间有 一个 空行
		outputStreamWriter.write(data.toString());
		outputStreamWriter.write("\r\n");
		outputStreamWriter.flush();

		// socket.shutdownOutput();

		bufferedReader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		String line = null;
		while ((line = bufferedReader.readLine()) != null) {
			System.out.println(line);
		}

		socket.close();
		outputStreamWriter.close();
		bufferedReader.close();

	}
}
```