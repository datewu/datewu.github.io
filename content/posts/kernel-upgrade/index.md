---
title: 内核升级
description: 升级centos 7 内核
date: 2018-05-16T16:50:31+08:00
tags: [
    "upgrade",
    "kernel",
    "grub2",
]
categories: [
    "运维",
]
cover:
  image: kernel.png
draft: false
---

众所周知centos的内核版本选择很保守，很多新内核的新特性，特别是网络和debug方面的特性都没有，所以我们来给centos升级下 kernel吧。

整个升级安装的过程其实挺简单的一共分为4步：

1. 找到repo源；
2. yum安装最新的kernel；
3. 修改grub2启动项；
4. 移除旧的kernel。
## 安装
### elrepo
访问[elrepo website](http://elrepo.org/tiki/tiki-index.php)查看对应 centos 版本最新的kernel repo源。
然后使用`rpm`添加kernel源：
```shell
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```

### install
安装内核：
```shell
yum --disablerepo="\*" --enablerepo="elrepo-kernel" list available
yum --enablerepo=elrepo-kernel install kernel-ml kernel-ml-devel
```

### boot
修改`grub2`启动项，开机使用新的内核：
```shell
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-set-default 0
init 6
```

### cleanup
删除旧内核
```shell
yum install yum-utils
package-cleanup --oldkernels --count=1
uname -a
```

## 参考

[How to Upgrade Kernel on CentOS 7](https://www.howtoforge.com/tutorial/how-to-upgrade-kernel-in-centos-7-server/)

[How to Install or Upgrade to Kernel 4.15 in CentOS 7](https://www.tecmint.com/install-upgrade-kernel-version-in-centos-7/)
