---
title: Java代码行数的统计
date: 2015-02-11 17:32:58
tags:
   
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

闲着没事想统计一下项目的java代码行数，最方便的就是执行linux命令：
<!--more-->
```
 find . -type f -name "*.java" -print0 | xargs -0 wc -l
```
`.`代表当前目录
`-type f `代表查找某一类型的文件，f代表普通文件
`-name` 按文件名查找文件
`*.java` 代表已.java为后缀的文件
`-print find`命令将匹配的文件输出到标准输出，`-print` 在每一个输出后会添加一个回车换行符，而`-print0`则不会
`xargs -0`将`\0`作为定界符，`xargs`的默认命令是`echo`，空格是默认定界符
`wc` 统计指定文件中的字节数、字数、行数，并将统计结果显示输出
 > 命令参数：
    `-c` 统计字节数。
    `-l` 统计行数。
    `-m`统计字符数。这个标志不能与` -c` 标志一起使用。
   ` -w` 统计字数。一个字被定义为由空白、跳格或换行字符分隔的字符串。
   `-L` 打印最长行的长度。
    `-help` 显示帮助信息
    `--version` 显示版本信息

随后又尝试用java代码写了一个函数：

```
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;

public class CountCodeLines {

    public static void main(String[] args) {
        CountCodeLines countCodeLines = new CountCodeLines();
        String path = "文件目录";
        System.out.println(path);
        int count = countCodeLines.getFiles(path, 0);
        System.out.print(count);
    }

    private int getFiles(String path, int count) {
        File file = new File(path);
        if (!file.exists() || file.listFiles().length == 0) {
            return count;
        }

        for (File file1 : file.listFiles()) {
            int s = 0;
            if (file1.isDirectory()) {
                count = getFiles(file1.getAbsolutePath(), count);
            } else {
                System.out.print(file1.getAbsolutePath());
                if (!file1.getName().endsWith(".java")) {
                    return count;
                }
                try {
                    LineNumberReader lineNumberReader = new LineNumberReader(new InputStreamReader(new FileInputStream(file1)));
                    while (lineNumberReader.readLine() != null) {
                        count++;
                        s++;
                    }
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                System.out.println(" count：" + s);

            }
        }

        return count;
    }
}
```

#### linux 命令参考：

[http://www.cnblogs.com/skynet/archive/2010/12/25/1916873.html](http://www.cnblogs.com/skynet/archive/2010/12/25/1916873.html)

[http://man.linuxde.net/xargs](http://man.linuxde.net/xargs)

[http://www.cnblogs.com/peida/archive/2012/12/18/2822758.html](http://www.cnblogs.com/peida/archive/2012/12/18/2822758.html)

[http://www.ahlinux.com/start/cmd/433.html](http://www.ahlinux.com/start/cmd/433.html)













