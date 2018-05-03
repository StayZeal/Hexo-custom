---
title: Java装箱和拆箱字节码分析
date: 2018-04-10 17:32:58
tags:
     - Java
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

<!--more-->
#### 示例代码：
```
/**
 * 拆箱操作：对象类型->基本的数据类型
 * 装箱操作：基本数据类型->对象类型
 */
class AutoBox {
    public static void main(String[] args) {
        /**
         * 以下7行装箱操作，即基本数据类型->对象类型，调用Integer.valueOf()/Long.valueOf();
         */
        Integer a = 1;
        Integer b = 2;
        Integer c = 3;
        Integer d = 3; //数值在[-128,127]的Integer的装箱操作返回相同的对象，其他范围返回不同的对象
        Integer e = 321;
        Integer f = 321;
        Long g = 3L;
        System.out.println(c == d);//不会进行拆箱操作，直接比较地址
        System.out.println(e == f);//不会进行拆箱操作，直接比较地址
        System.out.println(c == (a + b));//遇到算数运算符会进行拆箱操作，比较值
        System.out.println(c.equals(a + b)); //equals 先判断类型，再比较值
        System.out.println(g == (a + b));// 遇到算数云算法进行拆箱，然后类型转换
        System.out.println(g.equals(a + b));//进行拆箱操作，然后装箱，然后比较类型
    }
}
```
#### 输出结果：
>true
false
true
true
true
false

#### 对应的字节码：
```
 public static void main(java.lang.String[]);
   descriptor: ([Ljava/lang/String;)V
   flags: ACC_PUBLIC, ACC_STATIC
   Code:
     stack=5, locals=8, args_size=1
        0: iconst_1
        1: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        4: astore_1
        5: iconst_2
        6: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        9: astore_2
       10: iconst_3
       11: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
       14: astore_3
       15: iconst_3
       16: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
       19: astore        4
       21: sipush        321
       24: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
       27: astore        5
       29: sipush        321
       32: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
       35: astore        6
       37: ldc2_w        #3                  // long 3l
       40: invokestatic  #5                  // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
       43: astore        7
       45: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
       48: aload_3
       49: aload         4
       51: if_acmpne     58
       54: iconst_1
       55: goto          59
       58: iconst_0
       59: invokevirtual #7                  // Method java/io/PrintStream.println:(Z)V
       62: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
       65: aload         5
       67: aload         6
       69: if_acmpne     76
       72: iconst_1
       73: goto          77
       76: iconst_0
       77: invokevirtual #7                  // Method java/io/PrintStream.println:(Z)V
       80: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
       83: aload_3
       84: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
       87: aload_1
       88: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
       91: aload_2
       92: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
       95: iadd
       96: if_icmpne     103
       99: iconst_1
      100: goto          104
      103: iconst_0
      104: invokevirtual #7                  // Method java/io/PrintStream.println:(Z)V
      107: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
      110: aload_3
      111: aload_1
      112: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
      115: aload_2
      116: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
      119: iadd
      120: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
      123: invokevirtual #9                  // Method java/lang/Integer.equals:(Ljava/lang/Object;)Z
      126: invokevirtual #7                  // Method java/io/PrintStream.println:(Z)V
      129: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
      132: aload         7
      134: invokevirtual #10                 // Method java/lang/Long.longValue:()J
      137: aload_1
      138: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
      141: aload_2
      142: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
      145: iadd
      146: i2l
      147: lcmp
      148: ifne          155
      151: iconst_1
      152: goto          156
      155: iconst_0
      156: invokevirtual #7                  // Method java/io/PrintStream.println:(Z)V
      159: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
      162: aload         7
      164: aload_1
      165: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
      168: aload_2
      169: invokevirtual #8                  // Method java/lang/Integer.intValue:()I
      172: iadd
      173: invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
      176: invokevirtual #11                 // Method java/lang/Long.equals:(Ljava/lang/Object;)Z
      179: invokevirtual #7                  // Method java/io/PrintStream.println:(Z)V
      182: return
```