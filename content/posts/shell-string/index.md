---
title: 字符串
description: 什么是Linux/Unix system admin的全部工作内容
date: 2015-05-17T15:11:27+08:00
tags: [
    "shell",
    "string",
]
categories: [
    "运维",
]
cover:
  image: comma-seperator.png
draft: false
---

运维人员/系统管理员每天要在终端敲入大量命令，也要修改查看大量文本配置文件，日志信息。
甚至可以夸张一点说Linux/Unix system admin的全部工作就是和字符串打交道。

## binary
大家都知道文本文件是字符串组成的，其实二进制文件里面其实也包含了很多字符串：
```shell
➜  infra-api git:(dev) file infra-api
infra-api: Mach-O 64-bit executable x86_64
➜  infra-api git:(dev) strings infra-api | head
flag
hash
mime
path
sort
sync
time
*int
AAAA
Addr
➜  infra-api git:(dev)
```

## 命令
收集一些常用的shell 字符串操作命令

### cut

```shell
❯ tldr cut
  Cut out fields from stdin or files.
  More information: https://www.gnu.org/software/coreutils/cut.

  - Cut out the first sixteen characters of each line of stdin:
    cut -c 1-16
  - Cut out the first sixteen characters of each line of the given files:
    cut -c 1-16 file
  - Cut out everything from the 3rd character to the end of each line:
    cut -c 3-
  - Cut out the fifth field of each line, using a colon as a field delimiter (default delimiter is tab):
    cut -d':' -f5
  - Cut out the 2nd and 10th fields of each line, using a semicolon as a delimiter:
    cut -d';' -f2,10
  - Cut out the fields 3 through to the end of each line, using a space as a delimiter:
    cut -d' ' -f3-
```

### cat/less
cat，主要有三大使用场景：

一次显示整个文件 `cat filename`;
从标准输入流（键盘）新建一个文件。`cat > filename`;
将几个文件合并为一个文件： `cat file1 file2 > file`。
参数：
-n 或 --number 由 1 开始对所有输出的行数编号
-b 或 --number-nonblank 和 -n 相似，只不过对于空白行不编号
-s 或 --squeeze-blank 当遇到有连续两行以上的空白行，就代换为一行的空白行
-v 或 --show-nonprinting
例：
1. 把 textfile1 的档案内容加上行号后输入 textfile2 这个档案里
```shell
cat -n textfile1 > textfile2
```

2. 把 textfile1 和 textfile2 的档案内容加上行号（空白行不加）之后将内容附加到 textfile3 里。
```shell
cat -b textfile1 textfile2 >> textfile3
```
 
3. 清空test.txt
```shell
cat /dev/null > /etc/test.txt  
```
**另外，本文读取文件的操作可用less命令替代，less命令速度会更快些**

### awk
awk可以算独立的一门编程语言，举两个例子：
1. 截取路由器MAC地址后四位
```shell
$(cat /sys/class/ieee80211/${dev}/macaddress) | awk -F ":" '{ print $5""$6 }' | tr a-z A-Z

echo sd:3s:xf:0h:w4:n8 | awk -F ":" '{ print $5""$6 }' | tr a-z A-Z
W4N8
```

2. 对某一列求和
```shell
awk -F',' '{sum+=$2;} END{print sum;}' file.txt
```

#### 运行方式

1. 命令行方式
```shell
awk [-F  field-separator]  'commands'  input-file(s)
```
其中，commands 是awk命令，[-F域分隔符]是可选的。 input-file(s) 是待处理的文件。
在awk中，文件的每一行中，由域分隔符分开的每一项称为一个域。通常，在不指名-F域分隔符的情况下，默认的域分隔符是空格。

2. 脚本方式
  将所有的awk指令写入一个文件，并使awk程序可执行，然后把awk解释器作为脚本的首行，即可运行awk脚本。
把脚本首行（magic bang）：`#!/bin/sh` 换成： `#!/bin/awk` 即可，以 `which awk` 的输出为准。

3. 将所有的awk命令插入一个单独文件，然后调用：
```shell
awk -f awk-script-file input-file(s)
```
其中，-f选项加载awk-script-file中的awk脚本，input-file(s)跟上面的是一样的。


### tr
tr 命令从标准输入删除或替换字符，并将结果写入标准输出。根据由 String1 和 String2 变量指定的字符串以及指定的标志，tr 命令可执行三种操作。

本文使用了简单的**替换**操作。*小写字母转为大写字母。*
