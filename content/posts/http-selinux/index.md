---
title: 配置http selinux
description: 修改seLinux标签，放行http服务
date: 2018-04-16T16:10:45+08:00
tags: [
    "http",
    "selinux",
    "403",
    "nginx",
]
categories: [
    "运维",
]
cover:
  image: selinux.webp
draft: false
---

今天在`digitocean`一台新申请的主机上部署web应用。部署完成，打开浏览器发现报错403。

部署的web应用很简单，后端用nginx做了[反向代理](/posts/nginx-proxy/)，应该没啥大问题。

进一步打开chrome的console，发现对`static file`的访问报错`403`，还没到后端就已经报错了，
估计后面的 upstream socket也会报错。

`ssh`登陆到服务器上看了下nginx的日志，发现是权限的问题。

进一步debug了之后发现虚拟机开启selinux，当时心头就一紧，估计要改selinux配置了，这是个麻烦事儿。

想简单点直接关闭selinux，转念一想`digitocean`的主机直接暴露在interner上，开着selinux 其实是个很好的保护。`digitocean`打开自有它打开的道理，我猜可能有很多vm被攻破沦为僵尸网络了。

google搜索了selinux的web server常用的配置，验证后，解决了`nginx 403`的问题。记录分享如下：

## check seLinux
### 查看系统状态
[查看selinux配置和状态](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/sec-selinux-status-viewing.html)

```shell
[root@deo ~]# sestatus -v
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      28

Process contexts:
Current context:                unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
Init context:                   system_u:system_r:init_t:s0
/usr/sbin/sshd                  system_u:system_r:sshd_t:s0-s0:c0.c1023

File contexts:
Controlling terminal:           unconfined_u:object_r:user_devpts_t:s0
/etc/passwd                     system_u:object_r:passwd_file_t:s0
/etc/shadow                     system_u:object_r:shadow_t:s0
/bin/bash                       system_u:object_r:shell_exec_t:s0
/bin/login                      system_u:object_r:login_exec_t:s0
/bin/sh                         system_u:object_r:bin_t:s0 -> system_u:object_r:shell_exec_t:s0
/sbin/agetty                    system_u:object_r:getty_exec_t:s0
/sbin/init                      system_u:object_r:bin_t:s0 -> system_u:object_r:init_exec_t:s0
/usr/sbin/sshd                  system_u:object_r:sshd_exec_t:s0

```
### 查看文件目录的selinux label
```shell
[root@deo ]# ls -Z /opt/todolist
-rw-r--r--. root root unconfined_u:object_r:admin_home_t:s0 index.html
drwxr-xr-x. root root unconfined_u:object_r:admin_home_t:s0 static
[root@deo ]# ls -Z /usr/share/nginx/html
-rw-r--r--. root root system_u:object_r:httpd_sys_content_t:s0 50x.html
-rw-r--r--. root root system_u:object_r:httpd_sys_content_t:s0 index.html
```
 
## meat
下面两种方法选一种就可以了
### label
修改目录label使得selinux 放行nginx:
```shell
chcon -Rt httpd_sys_content_t /opt/todolist/
ls -Z /opt/todolist/
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 index.html
drwxr-xr-x. root root unconfined_u:object_r:httpd_sys_content_t:s0 static

setsebool -P httpd_can_network_connect 1 ; setsebool -P httpd_enable_homedirs on
chmod 701 /home/dir

```

### semanage
或者使用`semanage`命令修改`enforcement mode`：
```shell
~ [root@jp ~]# cat fix_selinux_ng.sh
semanage permissive -a httpd_tp

```
`segmanage`语法：
```shell
[root@jp ~]# semanage -h
usage: semanage [-h]
                {import,export,login,user,port,ibpkey,ibendport,interface,module,node,fcontext,boolean,permissive,dontaudit}
                ...

semanage is used to configure certain elements of SELinux policy with-out
requiring modification to or recompilation from policy source.

positional arguments:
  {import,export,login,user,port,ibpkey,ibendport,interface,module,node,fcontext,boolean,permissive,dontaudit}
    import              Import local customizations
    export              Output local customizations
    login               Manage login mappings between linux users and SELinux
                        confined users
    user                Manage SELinux confined users (Roles and levels for an
                        SELinux user)
    port                Manage network port type definitions
    ibpkey              Manage infiniband ibpkey type definitions
    ibendport           Manage infiniband end port type definitions
    interface           Manage network interface type definitions
    module              Manage SELinux policy modules
    node                Manage network node type definitions
    fcontext            Manage file context mapping definitions
    boolean             Manage booleans to selectively enable functionality
    permissive          Manage process type enforcement mode
    dontaudit           Disable/Enable dontaudit rules in policy

optional arguments:
  -h, --help            show this help message and exit
```

## 参考

[Fixing 403 errors when using nginx with SELinux](https://thecruskit.com/fixing-403-errors-when-using-nginx-with-selinux/)

[NGinX cannot connect to Jenkins on CentOS 7](https://stackoverflow.com/questions/25995060/nginx-cannot-connect-to-jenkins-on-centos-7)

[ Nginx refuses to read new directory in /home](https://serverfault.com/questions/686732/nginx-refuses-to-read-new-directory-in-home)
