---
title: Java Scoket实现Http服务器处理Post请求
date: 2018-03-29 17:32:58
tags:
     - Java
     - Socket
     - Post
---
博客地址：http://blog.stayzeal.cn

Post请求Header格式：
```
POST / HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Content-Length: 4105
Host: 192.168.3.26
Connection: Keep-Alive
Accept-Encoding: gzip
User-Agent: okhttp/3.8.0

table_name=ACCELERATION&db_data=%7B%22errorMessage%22%3Anull%2C%22isEditable%22%3Atrue%2C%22isSelectQuery%22%3Atrue%2C%22isSuccessful%22%3Atrue%2C%22rows%22%3A%5B%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A1%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A13.322282791137695%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A2%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A313.62994384765625%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A3%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A311.4601745605469%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A4%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A309.58984375%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A5%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A310.34368896484375%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A6%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A438.38037109375%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A7%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A438.5718688964844%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A8%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A308.0724792480469%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A9%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A439.183837890625%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A10%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A308.8055114746094%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A11%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A312.658447265625%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A12%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A13.432709693908691%7D%5D%2C%5B%7B%22dataType%22%3A%22text%22%2C%22value%22%3A%222018%E5%B9%B403%E6%9C%8826%E6%97%A5%20%20%20%2011%3A12%3A16%20%20%20%20%20%20%E5%BC%80%E5%A7%8B%22%7D%2C%7B%22dataType%22%3A%22integer%22%2C%22value%22%3A13%7D%2C%7B%22dataType%22%3A%22real%22%2C%22value%22%3A13.451769828796387%7D%5D%5D%2C%22tableInfos%22%3A%5B%7B%22isPrimary%22%3Atrue%2C%22title%22%3A%22date%22%7D%2C%7B%22isPrimary%22%3Afalse%2C%22title%22%3A%22time%22%7D%2C%7B%22isPrimary%22%3Afalse%2C%22title%22%3A%22acceleration%22%7D%5D%7D

```
其中最后一行为post的的参数，和其他header描述之间有一个空行，而且参数是经过urlencoded转码的。
<!-- more-->
```
public class Test {

	private ServerSocket mServerSocket;
	private int mPort = 80;

	private void tet() {
		try {
			mServerSocket = new ServerSocket(mPort);
			Socket socket = mServerSocket.accept();
			InetAddress addr = socket.getInetAddress();
			Log.i("客户端ip: " + addr.getHostAddress() + ":" + mPort + "  " + System.currentTimeMillis() / 1000);

			handle(socket);
			socket.close();
		} catch (SocketException e) {
			// The server was stopped; ignore.
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception ignore) {

			ignore.printStackTrace();
		}
	}

	public void handle(Socket socket) {

		BufferedReader reader = null;
		PrintStream output = null;
		try {
			String route = null;
			StringBuffer request = new StringBuffer();

			// Read HTTP headers and parse out the route.
			reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			String line;
			int postDataI = -1;
			Log.i("Header:");
            //line为0表示换行
			while ((line = reader.readLine())=null&&line.length!=0) {
				if (line.startsWith("GET /")) {
					int start = line.indexOf('/') + 1;
					int end = line.indexOf(' ', start);
					route = line.substring(start, end);

				    Log.i(route);
					return;
				}
//获取Content-Length:的长度，Content-Length:+空格总共16个字符
				if (line.indexOf("Content-Length:") > -1) {
					postDataI = new Integer(line.substring(line.indexOf("Content-Length:") + 16, line.length()))
							.intValue();
				}
				Log.i(line);

			}

			String postData = "";
			// 获取post参数，从空行开始读
			if (postDataI > 0) {
				char[] charArray = new char[postDataI];
				reader.read(charArray, 0, postDataI);
				postData = new String(charArray);
			}

			// 替换特殊字符
			postData = postData.replaceAll("%(?![0-9a-fA-F]{2})", "%25");
			// utf-8编码
			postData = URLDecoder.decode(postData, "utf-8");

			Log.i("route:" + route);
			output = new PrintStream(socket.getOutputStream());

			// Send out the content.
			output.println("HTTP/1.1 200 OK");
			output.println("Content-Type: " + "application/octet-stream");

			String responseStr = "";
			byte[] bytes = responseStr.getBytes();
			output.println("Content-Length: " + bytes.length);
			output.println();
			output.write(bytes);
			output.flush();

		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (null != output) {
					output.close();
				}
				if (null != reader) {
					reader.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
```