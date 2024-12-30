---
title:  重新安装macport
description: 无法删除/opt/local目录
date: 2021-11-29T11:50:01+08:00
lastmod: 2021-11-29T15:50:01+08:00
tags: [
    "macport",
    "postgresql",
    "macos",
    "sip",
]
categories: [
    "开发",
]
cover:
  image: sip.png
draft: false
---

updated: 好像是因为我安装了`ripgrep`所以会一直更新`cargo-c`依赖。

不知道为啥每次`sudo port -v upgrade outdated `都会重新安装`cargo-c`，
进而会安装编译`rust`。 编译`rust`很费时间和CPU风扇。

所以我就卸载了`rust`和一众依赖，后面特意又卸载了`cargo-c`。但是每次`upgrade outdated` 
`cargo-c`又回来了，很是烦人。 google一圈后，决定重新安装`macport`

## 清理安装包
尝试[`clean` 所有的](https://superuser.com/questions/165652/how-can-i-clean-up-my-macports-installation)安装包：
```shell
sudo port uninstall cargo-c
sudo port -v selfupdate
sudo port -f clean --all all
sudo rm -rf /opt/local/var/macports/packages/*
sudo rm -rf /opt/local/var/macports/distfiles/*
sudo rm -rf /opt/local/var/macports/build/*
port echo leaves
sudo port uninstall leaves
sudo port -f uninstall inactive

## SURPRISE! after upgrade, `cargo-c` come back.
sudo port upgrade outdated
```
## 卸载macport
参考[官网协助](https://guide.macports.org/chunked/installing.macports.uninstalling.html)步骤：

```shell
sudo port -fp uninstall installed
sudo dscl . -delete /Users/macports
sudo dscl . -delete /Groups/macports
sudo rm -rf \
    /opt/local \
    /Applications/DarwinPorts \
    /Applications/MacPorts \
    /Library/LaunchDaemons/org.macports.* \
    /Library/Receipts/DarwinPorts*.pkg \
    /Library/Receipts/MacPorts*.pkg \
    /Library/StartupItems/DarwinPortsStartup \
    /Library/Tcl/darwinports1.0 \
    /Library/Tcl/macports1.0 \
    ~/.macports

```
最后一步报错了：这三个`/opt/local`, `/opt/local/var/db`, `/opt/local/var/db/postgres`
目录无法删除。

`sudo su `切换为root还是报权限不足。

## SIP
查了一下是[system integrity proction(SIP)](https://superuser.com/questions/1049689/which-folders-are-affected-by-system-integrity-protection)的原因

### 查看SIP
#### 状态
```shell
❯ csrutil status
System Integrity Protection status: enabled.
```
#### 查看[用户](https://apple.stackexchange.com/questions/317576/how-to-delete-macports-user-after-using-the-migration-assistant/320714#320714)
```shell
dscl . list /Users | grep -v '^_'
daemon
Guest
postgres
mixelpix
nobody
root

```

### 删除postgres
可以看到上面有postgres用户，所以删除`postgres`之后，就可以删除`/opt/local`目录了：
```shell
sudo dscl . -delete /Groups/postgres
sudo dscl . -delete /Users/postgres

sudo rm -rf /opt/local

```

