---
title: "Expect自动化工具简介"
description: 自动化运维
date: 2020-03-19T16:07:45+08:00
tags: [
    "script",
    "automation",
    "unix",
]
categories: [
    "开发",
    "运维",
]
cover:
  image: automate.jpeg
draft: false
---
公司服务器使用了两层跳板机，外面的一台我们管它叫 `server A`， 另外一台 叫它 `server B`。

虽然我不知道这种双保险给公司带来了多少安全感，但是我知道我的运维效率降低了差不多90%吧 :>。

 

`server A`被直接暴露在公网上， 我们不能使用 `ssh key` 只能使用 `password`认证`ssh`。

这还不算完，`server A`每3小时改一次自己的`root`密码。

后面的`server B`跳板机器的自我安全感就强多了，`server B`可以直接免密使用`ssh key`登陆所有的内网服务器，而且允许`server A`免密登陆到自己。


我决得这样两次登录很浪费时间，于是写了个脚本从外网一次性登陆到`server B`服务器上。
## expect 脚本
```shell
#!/usr/bin/expect -f

# for anyone not familar with expect
# should read this awesome post
# https://www.pantz.org/software/expect/expect_examples_and_tips.html

set timeout 15
### CHANGE pwd every 3h
set pwd "mySuperSecretpwd123"
set nested_ssh "ssh server_B"

## for debug
# log_user 0
# exp_internal 1


send_user "going to connected to server A\n"
spawn ssh -q -o StrictHostKeyChecking=no server_A

expect {
    timeout { send_user "\ntimeout Failed to get password prompt, is VPN on?\n"; exit 1 }
    eof { send_user "\nSSH failure for server A\n"; exit 1 }
    "*assword:"
}

send "$pwd\r"

expect {
    timeout {send_user "\nSSH failure for server B\n"; exit 1 }
    "Last login:*"
}

send "$nested_ssh\r"
interact

```

### 基本语法
简单说下基本流程如下：

1. set: 设置变量；
2. spawn: 给对象一个进程空间，让对象可以运行起来
3. expect: 模拟用户等待，**期待**对象输出字符串；
4. send: 模拟用户输入，给对象发送字符串；
5. send_user: 提示用户;
6. interact: 用户直接和对象通信，expect不再在中间传话了。

因为`expect`语法继承自`Tcl`，所以变量赋值/初始化的方式和 `Bash`不同，需要使用`set`关键字。

注意第5点`send_user`命令是为了更好的用户交互，主要是给用户一下提示信息/反馈信息。

最后注意：`send "$pwd\r"`语句的[转以符](/posts/carrier-return/)是 `\r` 而不是`\r\n`。


##  详细语法
`expect`详细的语法和参数解释参考[Expect examples and tips](https://www.pantz.org/software/expect/expect_examples_and_tips.html)


> Expect is an automation and testing tool used to automate a process that receives interactive commands. If you can connect to any machine using ssh, telnet, ftp, etc then you can automate the process with an expect script. This works even with local programs where you would have to interact with a script or program on the command line.


