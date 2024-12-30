---
title: 增加固件大小
description: 把wr703n路由器固件大小翻一倍
date: 2015-05-07T11:45:48+08:00
tags: [
    "openwrt",
    "firmware",
    "router",
]
categories: [
    "开发",
]
cover:
  image: wr703n.jpeg
draft: false
---

很多路由器的flash容量只有4m大，所以绝大多数openwrt固件也是4m大小。
当我们手动改造路由器加大flash容量后，可以调整openwrt默认设置使得编译出来的factory可以有8m的大小，
从而安装更多的内置软件。

本文以wr703n路由器 为例子，简单介绍一下如何加大固件的容量，让我们预安装更多内置软件。
### 查看
```shell
# ./tools/firmware-utils/src/mktplinkfw.c
fw_max_len为0xfc0000，16M flash
fw_max_len为0x7c0000，8M flash    

```
### 修改
```makefile
# ./target/linux/ar71xx/image/Makefile
# 将703n的4Mlzma改为8Mlzma或16Mlzma
    $(eval $(call SingleProfile,TPLINK-LZMA,$(fs_64kraw),TLWR703,tl-wr703n-v1,TL-WR703N,ttyATH0,115200,0x07030101,1,8Mlzma))

```
