---
title: 查看Wi-Fi密码
description: 使用security命令查看所有Wi-Fi密码
date: 2021-12-01T15:16:39+08:00
tags: [
    "wifi",
    "macos",
]
categories: [
    "开发",
]
cover:
  image: wifi-password.jpeg
draft: false
---

在苹果电脑上使用终端`security`命令查看Wi-Fi密码：
```shell
security find-generic-password -wa 'your wifi-ssid'
```
![macos dialogue](wifi.png)
在弹出的系统对话框中输入正确的用户名和密码，终端即可以看到Wi-Fi密码。

ps. 除了当前连接的Wi-Fi，系统所有保存过的Wi-Fi密码都可以通过`security`命令查到。
![macos all remember wifi list](all-wifi.png)
