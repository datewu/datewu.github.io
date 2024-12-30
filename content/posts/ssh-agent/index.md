---
title: "SSH代理（Agent）"
description: 在服务器上安全的使用本地laptop的ssh密钥
date: 2020-04-12T11:34:44+08:00
tags: [
    "ssh",
]
categories: [
    "运维",
    "测试",
]
cover:
  image: ssh-agent-typical.png
draft: false
---

## 问题
已知本地local可以ssh到server A和B，

问如何从server A ssh到server B，以及如何在server A 和B之间使用scp互传文件 ？

## 解决方案

配置`ssh_config`然后使用 `ssh-add`命令指定使用ssh agent可以很安全和高效的解决上面的两个问题。
### 配置ssh_config
注意看注释，下面脚本所有的操作和配置都是在 本地local上执行的:
```shell
 vi .ssh/config  ## 修改配置 添加forward agent

HOST server-A
  HostName 1.2.3.4
  User root
  IdentityFile ~/.ssh/serverA
  ForwardAgent yes # 现在 serverA可以和local本机的agent通信啦

HOST server-B
  HostName 6.7.8.9
  User root
  IdentityFile ~/.ssh/serverB
  ForwardAgent yes # 现在 serverB可以和local本机的ssh agent 通信啦

 rg Forward /etc/ssh/ssh_config ## 检查全局的forwordagent配置有没有被覆盖

 echo "$SSH_AUTH_SOCK" ## 查看本地ssh agent是否在运行

 ssh-add -L  ## 查看/操作/删除 ssh agent hold的keys
 ssh-add -K li
 ssh-add -K ~/.ssh/serverA ## 给agent serverA 密钥，使得serverB 可以“使用” 这个密钥
 ssh-add -K ~/.ssh/serverB ## 给agent serverB密钥，使得serverA可以“使用”这个密钥
 ssh-add -K ~/.ssh/github  ## 给阿根廷 github密钥，使得serverA， serverB都可以ssh github，方便测试
 ssh-add -L
```

### 验证github
也是在本机local操作，以[github](https://developer.github.com/v3/guides/using-ssh-agent-forwarding/#troubleshooting-ssh-agent-forwarding)作为测试目标：
```shell
ssh -T git@github.com ## 本地基准测试

ssh serverA ## 测试serverA 
ssh -T git@github.com ## 测试/验证
```
## 小结
注意看注释，注意`ForwardAgent`配置应用到哪个server上了。

当 server 可以和local本机的agent通信的时候，就表示 server 好像拥有了local本地的private keys了。

具体说： 当server A 的 ForwardAgent 开启时， server A就可以直接ssh到server B了，

如果这个时候 server B 的ForwordAgent没有开启，server B是不可以ssh 到server A的
