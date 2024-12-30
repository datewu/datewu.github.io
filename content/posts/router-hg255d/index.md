---
title: "刷机HG255d"
description: 本文简单回顾编译openwrt固件流程
date: 2015-03-17T09:09:58+08:00
tags: [
    "linux",
    "shadowsocks",
    "openwrt",
]
categories: [
    "开发",
]
cover:
  image:  "hg255d.jpg"
draft: false
---

## 交叉编译
1. 在ubuntu下安装编译工具（gcc,xmllib,cmake, git 等)；
2. git克隆openwrt仓库：`git clone git://git.openwrt.org/14.07/openwrt.git`；
3. 自定义kernel target：

  源代码做[两处修改](http://my.oschina.net/osbin/blog/278782) :
```bash
target/linux/ramips/image/Makefile
/base-files/lib/ramips.sh 
target/linux/ramips/base-files/lib/preinit/06_set_iface_mac
```
4. 在弹出的make menuconfig 图像界面中选择cpu型号；
5. 打开vpn开始编译固件。

## 结果
交叉编译完成后，根据上一步选择的安装包的多少，bin目录下会生成对应的opkg包，和固件：
1. factory文件，可以称作底包；
2. sysupgrade文件，可以称作升级包；

### web/uboot烧录刷机
1. 接通路由器电源，按住WPS按钮不放，然后按电源键开机， power LED快闪即松开WPS键，此时路由器已加入升级模式；
2. 访问路由器web地址（如：http://192.168.1.1), 按照web界面提示选取factory文件完成固件烧录刷机；

### ssh/ftp 烧录
可以直接执行`sysupgrade`命令烧录估计：
```shell
ssh-keygen -f "/home/openwrt-qqm/.ssh/known_hosts" -R 192.168.1.1 #可以省略此条命令 
scp xxxxxx-squashfs-sysupgrade.bin root@192.168.1.1:/tmp/
ssh root@192.168.1.1
cd /tmp/
sysupgrade -n xxxxxxxxxxx-sysupgrade.bin
```

### opkg
烧录完系统固件后，可以使用`opkg`安装软件包，比如`china-dns`, `shadowsocks`, `openvpn`，等等。

![hg255d router](hg255d.jpg)
