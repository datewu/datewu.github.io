---
title: "安装wireguard"
description: 试用wg vpn
date: 2020-01-06T16:50:26+08:00
tags: [
    "vpn",
    "udp",
    "wireguard",
    "iptables",
    "kernel",
]
categories: [
    "运维",
]
cover:
  image: site-to-site-complex.svg
draft: false
---

今天在hacker news上看到 wireguard macos client 发布了，决定试用一下。

和所有的vpn安装一样，wireguard的安装也是分两步，一是安装vpn server，二是安装 vpn的client。
安装不分先后，配置先配置server，然后在配置client。

## 服务端

### 安装
服务器为 RHEL  7.6 (Maipo)， 服务端的安装流程:
```shell
#!/bin/bash
sudo -i
[root@deoops ~]# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.6 (Maipo)
[root@deoops ~]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@deoops ~]# sysctl -p

### install packages
[root@deoops ~]#  curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
[root@deoops ~]#  yum  install -y  epel-release wireguard-dkms wireguard-tools
[root@deoops ~]#  yum  install -y  epel-release
[root@deoops ~]#  rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
[root@deoops ~]#  yum update -y
[root@deoops ~]#  yum  install -y  epel-release wireguard-dkms wireguard-tools
[root@deoops ~]#  init 6


```

### 配置

```shell
### wireguard server conf
[root@deoops ~]# cat wg.conf
[Interface]
ListenPort = 58855
PrivateKey = private_key


[Peer]
PublicKey = public_key_one
#AllowedIPs = 0.0.0.0/0
AllowedIPs = 10.0.0.7/32


[Peer]
PublicKey = public_key_two
#AllowedIPs = 0.0.0.0/0
AllowedIPs = 10.0.0.9/32


```

### 启动wg0 设备
记得加上`iptables`设置：
```shell
### start wg0 device
[root@deoops ~]# cat start-wireguard.sh
  ip l a dev wg0 type wireguard
  ip a a dev wg0 10.0.0.1/24
  wg setconf wg0 wg.conf
  ip l set up dev wg0
  iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT;
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

## 客户端

### 下载
在app store可以直接下载wireguard 客户端。

如果是中国大陆的app store， 则需要修改Apple ID的国家和地区才能下载wireguard客户端。

### 配置
注意 `[Peer]`的 Endpoint 和服务器端的`[Interface]`对上（都是58855端口)：
```ini
[Interface]
PrivateKey = private_key
ListenPort = 54123
Address = 10.0.0.9/32
DNS = 8.8.8.8, 1.1.1.1, 1.0.0.1, 8.8.4.4

[Peer]
PublicKey = server_public_key
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = server_address:58855
PersistentKeepalive = 30

```

## 折腾调试
安装完成后，可能会遇到vpn不通的问题，可以安装下面介绍的 
`udp` port troubleshoot方法调试调试： 
```shell
# nc on client to scan, and tcpdump on server side

### client side
➜  ~ nc -vz -u server 58885
## the -z option to perform a scan instead of attempting to initiate a connection.

### server side
[root@deoops ~]#  yum install tcpdump
[root@deoops ~]#  tcpdump -i eth0 udp port 58855 -vv -X
```

## 后记

体验一天，大体说来，wireguard比shadowsocks 速度快上6到8倍。

### kernel update

当我们对主机执行升级Linux kernel操作之后，需要重新load wireguard mod，否则 `ip link add ...`wg0的时候会报错。

这个时候 删除旧的 dkms mod， 然后add新的wireguard mod即可：

```shell
dkms status
ls /var/lib/dkms/wireguard/0.0.20191206/
ls -alh  /var/lib/dkms/wireguard/0.0.20191206/
ls -alh /var/lib/dkms/wireguard/0.0.20200105/
rm -rf /var/lib/dkms/wireguard/0.0.20191206
ls -alh /var/lib/dkms/wireguard/
rm -rf /var/lib/dkms/wireguard/kernel-4.18.0-80.11.2.el8_0.x86_64-x86_64

dkms status
dkms add -m wireguard/0.0.20200105
dkms status

vi /etc/wireguard/wg0.conf
wg-quick up /etc/wireguard/wg0.conf
```
