---
title: "设置dns"
description: 设置macos dns解析服务器
date: 2020-06-10T22:20:03+08:00
tags: [
    "macos",
    "dns",
    "networksetup",
    "setdnsservers",
]
categories: [
    "运维",
]
cover:
  image: dns-resolver.png
draft: false
---
众所周知，修改[`/etc/resolv.conf`](https://en.wikipedia.org/wiki/Resolv.conf)配置文件可以配置Linux的dns 解析服务器。
```shell
[root@VM-8-3-centos ~]# cat /etc/resolv.conf 
# Generated by NetworkManager
nameserver 183.60.83.19
nameserver 183.60.82.98
```

那么苹果系统的dns 解析服务器应该在哪里配置呢，也是配置/etc/resolv.conf文件吗？
```shell
➜  ~ cat /etc/resolv.conf 
# macOS Notice
#
# This file is not consulted for DNS hostname resolution, address
# resolution, or the DNS query routing mechanism used by most
# processes on this system.
#
# To view the DNS configuration used by this system, use:
#   scutil --dns
#
# SEE ALSO
#   dns-sd(1), scutil(8)
#
# This file is automatically generated.
#
nameserver 127.0.0.1
nameserver 192.168.1.1
```

## 故事

因为新冠的爆发，公司下放了VPN权限，可以在家接公司办公网络办公。

这段时间我在家享受丝滑顺畅的办公内网网络，基本没遇到啥问题，每天都美滋滋的。

昨天手机运营商**联通**突然打电话给我说，我的手机是5G手机，设置一下网络模式可以在原有4G的套餐上使用5G网络啦，诚邀我体验。

那么**联通**是**怎么知道**我使用的是5G手机的呢？？？这个先按下不表。

我稍稍体验了一会，5G网络的速度和时延果然和宣传中的一样牛逼。

我不由的感叹：华为果然🐂🍺。


这么好的网络质量，不应该让笔记本也享受享受吗？

话不多说我立马把苹果电脑连接上了手机热点，用了不多久就发现遇到了DNS的问题。

### 问题
苹果笔记本连接手机热点的Wi-Fi后，手机热点 不会使用 VPN指定的DNS server去解析 办公网络的内网地址，导致无妨访问内网域名。

### 解决方案
解决的办法也很简单：打开 设置-> 网络 -> WI-Fi -> 高级 -> DNS -> 修改DNS 服务器 即可。

鼓捣一会发现，每次操作dns server都需要用鼠标点击UI，再点击6次子菜单，复制两次DNS server 的IP 地址，才能完成设置，这种操作很不程序员。

于是搜索了macos设置dns servers的命令，把上面的UI操作脚本化了。整理了一份`bash`脚本如下：
```bash
#!/usr/local/bin/bash
a=${1:-check}
echo ${a}ing ...

#dns="100.67.174.10 100.67.174.11"
dns="100.67.174.10 100.67.174.11"

if [ $a = "check" ]
then
    networksetup -getinfo wi-fi
    echo ""
    networksetup -getdnsservers wi-fi
fi


if [ $a = "set" ]
then
    networksetup -setdnsservers wi-fi $dns
    echo ""
    networksetup -getdnsservers wi-fi
fi

if [ $a = "clear" ]
then
    networksetup -setdnsservers wi-fi Empty
    echo ""
    networksetup -getdnsservers wi-fi
fi

echo ""
echo $a successed!
```

脚本支持3个参数 `check`,`set`和 `clear`，默认使用 `check`参数。

保存为`set-dns.sh`文件，再加上可执行权限即可：
```shell
➜  ~ chmod +x set-dns.sh
➜  ~ ./set-dns.sh
```