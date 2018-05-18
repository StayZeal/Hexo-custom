---
title: Java 序列化static变量问题
date: 2015-05-12 17:32:58
tags:
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

Java序列化的时候能否序列化静态变量呢？经过在网上查找资料我得到这样的结论：

         1、用transient和static修饰的变量是不能被序列化的，但是通过在序列化的类中写writeObject(ObjectOutputStream stream)和readObject(ObjectInputStream stream)方法，可以实现序列化；

         2、被final修饰的static变量可以被直接序列化
<!--more-->
在以下代码中可以实现static修饰的变量序列化：
```
import java.io.*;
public class OverrideSerial implements Serializable {

	private static final long serialVersionUID = -1608783310676957433L;

	private static int count; // 用于计算OverrideSerial对象的数目
	private static final int MAX_COUNT = 1000;
	private String name;
	private transient String password = "origin";

	static {
		System.out.println("调用OverrideSerial类的静态代码块 ");
	}

	public OverrideSerial() {
		System.out.println("调用OverrideSerial类的不带参数的构造方法 ");
		count++;
	}

	public OverrideSerial(String name, String password) {
		System.out.println("调用OverrideSerial类的带参数的构造方法 ");
		this.name = name;
		this.password = password;
		count++;
	}

	/**
	 * 加密数组，将buff数组中的每个字节的每一位取反 例如13的二进制为00001101，取反后为11110010
	 */
	private byte[] change(byte[] buff) {
		for (int i = 0; i < buff.length; i++) {
			int b = 0;
			for (int j = 0; j < 8; j++) {
				int bit = (buff[i] >> j & 1) == 0 ? 1 : 0;
				b += (1 << j) * bit;
			}
			buff[i] = (byte) b;
		}
		return buff;
	}

	private void writeObject(ObjectOutputStream stream) throws IOException {
		stream.defaultWriteObject(); // 先按默认方式序列化
		stream.writeObject(change(password.getBytes()));
		stream.writeInt(count);
	}

	private void readObject(ObjectInputStream stream) throws IOException,
			ClassNotFoundException {
		stream.defaultReadObject(); // 先按默认方式反序列化
		byte[] buff = (byte[]) stream.readObject();
		password = new String(change(buff));
		count = stream.readInt();
	}

	public String toString() {
		return "count= " + count + "   MAX_COUNT= " + MAX_COUNT + "   name= "
				+ name + "   password= " + password;
	}

	public static void main(String[] args) throws IOException,
			ClassNotFoundException {

		FileOutputStream fos = new FileOutputStream("/OverrideSerial.txt");
		ObjectOutputStream oos = new ObjectOutputStream(fos);
		OverrideSerial osInput1 = new OverrideSerial("leo1","akiy1231");
		OverrideSerial osInput2 = new OverrideSerial("leo2","akiy1232");
		OverrideSerial osInput3 = new OverrideSerial("leo3","akiy1233");
		oos.writeObject(osInput1);
		oos.writeObject(osInput2);
		oos.writeObject(osInput3);
		oos.flush();
		oos.close();

		count =100;
		osInput1.name="change";

		FileInputStream fis = new FileInputStream("/OverrideSerial.txt");
		ObjectInputStream ois = new ObjectInputStream(fis);
		OverrideSerial osOutput1 = (OverrideSerial) ois.readObject();
		System.out.println(osOutput1.toString());
		OverrideSerial osOutput2 = (OverrideSerial) ois.readObject();
		System.out.println(osOutput2.toString());
		OverrideSerial osOutput3 = (OverrideSerial) ois.readObject();
		System.out.println(osOutput3.toString());
	}

}
```
上面的代码中无非就是多了两个方法：`writeObject(ObjectOutputStream stream)`和`readObject(ObjectInputStream stream)`，这样就可以实现static变量的序列化，但是我却没有发现在哪里这两个方法被调用。后来看了`ObjectInputStream`的`writeObject()`和`readObject()`的文档才知道，原来被序列化的对象如果重写这两个方法，就可以实现自定义序列化对象，`ObjectInputStream`对象会通过反射来调用这两个方法。

相关文章：

[http://837062099.iteye.com/blog/1462714](http://837062099.iteye.com/blog/1462714)

[http://www.cnblogs.com/xdp-gacl/p/3777987.html](http://www.cnblogs.com/xdp-gacl/p/3777987.html)        

[http://bluepopopo.iteye.com/blog/486548](http://bluepopopo.iteye.com/blog/486548)

```







