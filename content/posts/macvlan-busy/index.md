---
title: "无法创建macvlan设备"
description: "SIOCSIFFKAGS: Device or resource busy"
date: 2019-03-07T11:17:49+08:00
tags: [
    "network",
    "macvlan",
    "ip netns",
    "linux",
]
categories: [
    "运维",
    "测试",
]
cover:
  image: maxresdefault.jpeg
draft: false
---

最近给客户调试 macvlan network时，遇到了`Linux kernel` 报错
`SIOCSIFFKAGS: Device or resource busy.` 无法创建网络device。

结果长时间的debug分析，
发现问题是高并发压测 创建和释放`macvlan device`的时候，设备的`mac address`出现了重复。

ps：这个问题只出现在 `macvlan`network 的设备中。

可以用下面的shell脚本来复现macvlan `Device or resource busy`的错误：

```shell
#!/bin/bash
function setup
{
    i=$1
    ip l a m$i address 00:40:2F:4D:5E:6F link eth0 type macvlan mode bridge
    ip netns add ns$i
    ip l set m$i netns ns$i
    sleep 1
    ip netns exec ns$i ifconfig m$i 10.0.0.$((i+1))/24 up
    echo $?
}

echo cleaning up
ip -all netns d

echo creating netsnses
for i in `seq $1`; do
    echo $i....
    #setup $i &
    setup $i
done

```

如果把 macvlan 类型改为 dummy (上面脚本第5行 type macvlan 改为 type `dummy`) ，即使 MAC address 重复也不会引发kernel 报错。
