---
title: 安装配置openvpn
description: 在centos 7上安装配置openvpn sever服务和client服务
date: 2017-02-20T13:24:19+08:00
tags: [
    "centos",
    "openvpn",
    "openssl",
    "network",
]
categories: [
    "运维",
]
cover:
  image: openvpnflows.jpeg
draft: false
---

开发需要能调用`facebook`的接口，我们运维这边需要配置一台测试服务器能访问`facebook`，用shadowsocks
和squid 代理，性能不够好。所以决定上openvpn。

简单记录下openVPN的安装配置过程，服务端和客户端使用的操作系统均是centos 7。

## 服务端
### 安装

```shell
#!/bin/bash
yum install epel-release -y
yum install openvpn openssl -y
```
#### 自签名证书
使用`openssl`工具生产自签名的ca，证书，client.key，并把这些证书传给客户端：
```shell
#!/bin/bash

### CA
openssl dhparam -out /etc/openvpn/dh.pem 2048

openssl genrsa -out /etc/openvpn/ca.key 2048
openssl req -new -key /etc/openvpn/ca.key -out /etc/openvpn/ca.csr -subj /CN=OpenVPN-CA/
openssl x509 -req -in /etc/openvpn/ca.csr -out /etc/openvpn/ca.crt -signkey /etc/openvpn/ca.key -days 3650
echo 01 > /etc/openvpn/ca.srl
chmod 600 /etc/openvpn/ca.key

### Server 
openssl genrsa -out /etc/openvpn/server.key 2048
openssl req -new -key /etc/openvpn/server.key -out /etc/openvpn/server.csr -subj /CN=OpenVPN/
openssl x509 -req -in /etc/openvpn/server.csr -out /etc/openvpn/server.crt -CA /etc/openvpn/ca.crt -CAkey /etc/openvpn/ca.key -days 3650
chmod 600 /etc/openvpn/server.key

### Client
openssl genrsa -out /etc/openvpn/client.key 2048
openssl req -new -key /etc/openvpn/client.key -out /etc/openvpn/client.csr -subj /CN=OpenVPN-Client/
openssl x509 -req -in /etc/openvpn/client.csr -out /etc/openvpn/client.crt -CA /etc/openvpn/ca.crt -CAkey /etc/openvpn/ca.key -days 3650
chmod 600 /etc/openvpn/client.key


### 把clinet的证书私钥和ca正式传给客户端
scp /etc/openvpn/ca.crt /etc/openvpn/client.crt /etc/openvpn/client.key client:
```

### 配置
#### 服务端配置文件:
```shell
# /etc/openvpn/server.conf
server 10.8.0.0 255.255.255.0
verb 3
key /etc/openvpn/server.key
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
dh /etc/openvpn/dh.pem
keepalive 10 120
persist-key
persist-tun
comp-lzo
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"

user nobody
group nogroup

proto udp
port 1194
dev tun1194
status openvpn-status.log
```
#### kernel iptables
打开服务器路由配置：
```shell
#!/bin/bash
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
```
### 启动
服务器启动openVPN服务：
```shell
#!/bin/bash
systemctl enable openvpn@server
systemctl start openvpn@server
```

## 客户端
### 安装
```shell
#!/bin/bash
yum install epel-release -y
yum install openvpn -y
```

### 配置

#### 证书
把前面服务端签名的证书移动到配置目录下：
```shell
#!/bin/bash
mv ~/ca.crt /etc/openvpn
mv ~/client* /etc/openvpn/
```

#### 配置文件
```shell
# /etc/openvpn/client.conf
client
nobind
dev tun
redirect-gateway def1 bypass-dhcp
remote CHANGE_TO_YOUR_SERVER_IP 1194 udp
comp-lzo yes
#duplicate-cn

key /etc/openvpn/client.key
cert /etc/openvpn/client.crt
ca /etc/openvpn/ca.crt
```
### 启动
客户端启动openVPN服务：
```
#!/bin/bash
systemctl enable openvpn@client
systemctl start openvpn@client
```

[参考How to Install OpenVPN on CentOS 7](https://www.rosehosting.com/blog/how-to-install-openvpn-on-centos-7/)

