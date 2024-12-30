---
title: "tcl入门"
description: tcl是一门脚本语言，常常和tk图形工具结合使用
date: 2020-05-19T16:41:43+08:00
tags: [
    "tcl",
    "tutorial",
    "regexp",
]
categories: [
    "开发",
]
cover:
  image: tcl-tk.jpeg
draft: false
---


使用了一段时间[Expect自动化工具简介](/posts/expect-interactive/)里面的`expect`脚本，发现少了一些功能：

1. 怎么给`expect`脚本传参数呢？
2. `expect`怎么调用 `bash/sh`外部命令呢？
3. `expect`怎么操作字符串呢？

## tcl
前面的文章[Expect命令](/posts/expect-interactive/)里面提到过，expect 使用的是`Tcl/tk`的语法。

所以 大家Google 一下 `tcl tutorial`就可以解决上面三个问题了。

1. [tcl argc argc](https://wiki.tcl-lang.org/page/argv)

2. [Tcl tutorial](https://zetcode.com/lang/tcl/)

3. [Tcl regexp](https://www.tcl.tk/man/tcl8.4/TclCmd/regexp.htm)

### new expect script
结合上面的3篇教程我把上篇文章自动化ssh 登陆的脚本优化如下:
```shell
#!/usr/bin/expect -f

# for anyone not familar with expect
# should read this awesome article
# https://www.pantz.org/software/expect/expect_examples_and_tips.html

if { $argc != 1} {
        puts "must set one argument for server_A host ip"
        puts "./login.tcl 1.1.2.2"
        exit 1
}

set timeout 15

#set info [gets stdin]
set info [exec privateRESTfullAPI2GetPwd -host $argv]

set result [regexp {\"([^\"]*)\"[^\"]*\"([^\"]*)\"[^\"]*\"([^\"]*)\"} $info match host pw1 pw2]


send_user "going to connected to server_A\n"
spawn ssh -q -o StrictHostKeyChecking=no nobody@host

expect {
    timeout { send_user "\ntimeout Failed to get password prompt, is VPN on?\n"; exit 1 }
    eof { send_user "\nSSH failure for server_A\n"; exit 1 }
    "*assword:"
}

send "$pwd1\r"

expect {
    timeout {send_user "\nSSH failure for server_B\n"; exit 1 }
    "Last login:*"
}

send "su -\r"
expect {
    eof { send_user "\nSSH failure check your password \n"; exit 1 }
    "密码"
}
send "$pw2\r"

interact

```

简单解释上面的脚本：

1. $argc 命令行参数的个数； $argv 命令行参数（不含命令本身）;
2. `puts` 相当于 bash 的 `echo`命令 ;
3. `exec` 相当于 bash的 `$()`;
4. privateRESTfullAPI2GetPwd  -host $argv 是我本地的一个用来查询主机密码的工具，返回值的格式为：`Passworod of  "1.1.1.1" are "pwd for noby" and "pwd for root"`
5. 正则表达式 ` {\"([^\"]*)\"[^\"]*\"([^\"]*)\"[^\"]*\"([^\"]*)\"}`用来提取上面`privateAPI2GetPwd`返回值中3个 双引号中的内容， 即： host, pwd1, pwd2
6. 命令`set result [regexp {...第五条..} $info match host pw1 pw2]`把上面正则表达式的的3个 `group` 分别赋值给 `host, pw1, pw2`三个变量。 丢弃了`result` 和 `match` 两个变量。
