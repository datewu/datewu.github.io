---
title: "tcp性能调优"
description: "修改Linux TCP内核配置"
date: 2016-04-05T18:58:52+08:00
tags: [
    "linux",
    "tcp",
]
categories: [
    "运维",
]
cover:
  image: sysctl.jpeg
draft: false
---

我们一般会调整内核tcp参数以提高web服务器(比如ngin)的性能。

## sysctl

加载Linux 内核配置 

```bash
sysctl -p /etc/sysctl.d/xxx-xxx.conf
```

## meat

```shell
# /etc/sysctl.d/00-network.conf
# Receive Queue Size per CPU Core, number of packets
# Example server: 8 cores
net.core.netdev_max_backlog = 4096
# SYN Backlog Queue, number of half-open connections
net.ipv4.tcp_max_syn_backlog = 32768
# Accept Queue Limit, maximum number of established
# connections waiting for accept() per listener.
net.core.somaxconn = 65535
# Maximum number of SYN and SYN+ACK retries before
# packet expires.
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
# Timeout in seconds to close client connections in
# TIME_WAIT after receiving FIN packet.
net.ipv4.tcp_fin_timeout = 5
# Disable SYN cookie flood protection
net.ipv4.tcp_syncookies = 0
# Maximum number of threads system can have, total.
# Commented, may not be needed. See user limits.
#kernel.threads-max = 3261780
# Maximum number of file descriptors system can have, total.
# Commented, may not be needed. See user limits.
#fs.file-max = 3261780
```
