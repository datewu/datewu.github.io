---
title: 审计目录
description: 使用ausearch查看auditd系统日志，审计文件和目录
date: 2018-06-20T17:02:58+08:00
tags: [
    "docker",
    "audit",
    "ausearch",
    "monitor",
]
categories: [
    "运维",
]
cover:
  image: audit.jpeg
draft: false
---


今天调试容器应用的时候发现，app运行一段时间后，容器外挂的一个volumn会偶发性的被删除。
于是需要监控下到底是谁/哪个进程把文件目录给删除了。

google一阵子后，发现可以使用`auditd` 服务来监控和搜索出都有那些进程操作够目标文件/目录。

整个过程分为3步：

1. 开启 auditd 服务；
2. 使用auditctl 配置 auditd服务；
3. 一段时间之后 使用 ausearch 来查看/搜索审计的日志。

## 启动监控
开启`auditd`服务：
```shell
systemctl start auditd
## you may need `mkdir /var/log/audit`
```

## 添加监控规则
编辑审计规则：
```shell
## list existing rules
auditctl -l

## clean existing rules
auditctl -D

## watch /var/run/yourfolder
auditctl -w /var/run/yourfolder -p war -k serachkey
```
### auditctl语法
```shell
[root@ddeoops ~]# auditctl -h
usage: auditctl [options]
    -a <l,a>            Append rule to end of <l>ist with <a>ction
    -A <l,a>            Add rule at beginning of <l>ist with <a>ction
    -b <backlog>        Set max number of outstanding audit buffers
                        allowed Default=64
    -c                  Continue through errors in rules
    -C f=f              Compare collected fields if available:
                        Field name, operator(=,!=), field name
    -d <l,a>            Delete rule from <l>ist with <a>ction
                        l=task,exit,user,exclude
                        a=never,always
    -D                  Delete all rules and watches
    -e [0..2]           Set enabled flag
    -f [0..2]           Set failure flag
                        0=silent 1=printk 2=panic
    -F f=v              Build rule: field name, operator(=,!=,<,>,<=,
                        >=,&,&=) value
    -h                  Help
    -i                  Ignore errors when reading rules from file
    -k <key>            Set filter key on audit rule
    -l                  List rules
    -m text             Send a user-space message
    -p [r|w|x|a]        Set permissions filter on watch
                        r=read, w=write, x=execute, a=attribute
    -q <mount,subtree>  make subtree part of mount point's dir watches
    -r <rate>           Set limit in messages/sec (0=none)
    -R <file>           read rules from file
    -s                  Report status
    -S syscall          Build rule: syscall name or number
    -t                  Trim directory watches
    -v                  Version
    -w <path>           Insert watch at <path>
    -W <path>           Remove watch at <path>
    --loginuid-immutable  Make loginuids unchangeable once set
    --reset-lost         Reset the lost record counter
```

## 分析日志
查看/搜索 审计日志：
```shell
[root@deoops ~]# ausearch -k wiserun -i 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8377) : arch=x86_64 syscall=unlinkat success=no exit=ENOTEMPTY(目录非空) a0=0xffffffffffffff9c a1=0xc42038ca80 a2=0x200 a3=0x0 items=2 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8376) : arch=x86_64 syscall=unlinkat success=no exit=EISDIR(是一个目录) a0=0xffffffffffffff9c a1=0xc42038ca60 a2=0x0 a3=0x0 items=2 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8378) : arch=x86_64 syscall=openat success=yes exit=6 a0=0xffffffffffffff9c a1=0xc42038cae0 a2=O_RDONLY|O_CLOEXEC a3=0x0 items=1 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8379) : arch=x86_64 syscall=unlinkat success=no exit=EISDIR(是一个目录) a0=0xffffffffffffff9c a1=0xc42003e3c0 a2=0x0 a3=0x0 items=2 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8380) : arch=x86_64 syscall=unlinkat success=yes exit=0 a0=0xffffffffffffff9c a1=0xc42003e410 a2=0x200 a3=0x0 items=2 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8381) : arch=x86_64 syscall=unlinkat success=no exit=EISDIR(是一个目录) a0=0xffffffffffffff9c a1=0xc42038cb80 a2=0x0 a3=0x0 items=2 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 
type=SYSCALL msg=audit(2018年06月20日 14:22:33.669:8382) : arch=x86_64 syscall=unlinkat success=yes exit=0 a0=0xffffffffffffff9c a1=0xc42038cbc0 a2=0x200 a3=0x0 items=2 ppid=20523 pid=1890 auid=unset uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=(none) ses=unset comm=yes_i_changed_you exe=/root/yes_i_changed_you key=wiserun 

```

### ausearch语法
```shell
[root@deoops ~]# ausearch -h
usage: ausearch [options]
        -a,--event <Audit event id>     search based on audit event id
        --arch <CPU>                    search based on the CPU architecture
        -c,--comm  <Comm name>          search based on command line name
        --checkpoint <checkpoint file>  search from last complete event
        --debug                 Write malformed events that are skipped to stderr
        -e,--exit  <Exit code or errno> search based on syscall exit code
        -f,--file  <File name>          search based on file name
        -ga,--gid-all <all Group id>    search based on All group ids
        -ge,--gid-effective <effective Group id>  search based on Effective
                                        group id
        -gi,--gid <Group Id>            search based on group id
        -h,--help                       help
        -hn,--host <Host Name>          search based on remote host name
        -i,--interpret                  Interpret results to be human readable
        -if,--input <Input File name>   use this file instead of current logs
        --input-logs                    Use the logs even if stdin is a pipe
        --just-one                      Emit just one event
        -k,--key  <key string>          search based on key field
        -l, --line-buffered             Flush output on every line
        -m,--message  <Message type>    search based on message type
        -n,--node  <Node name>          search based on machine's name
        -o,--object  <SE Linux Object context> search based on context of object
        -p,--pid  <Process id>          search based on process id
        -pp,--ppid <Parent Process id>  search based on parent process id
        -r,--raw                        output is completely unformatted
        -sc,--syscall <SysCall name>    search based on syscall name or number
        -se,--context <SE Linux context> search based on either subject or
                                         object
        --session <login session id>    search based on login session id
        -su,--subject <SE Linux context> search based on context of the Subject
        -sv,--success <Success Value>   search based on syscall or event
                                        success value
        -te,--end [end date] [end time] ending date & time for search
        -ts,--start [start date] [start time]   starting data & time for search
        -tm,--terminal <TerMinal>       search based on terminal
        -ua,--uid-all <all User id>     search based on All user id's
        -ue,--uid-effective <effective User id>  search based on Effective
                                        user id
        -ui,--uid <User Id>             search based on user id
        -ul,--loginuid <login id>       search based on the User's Login id
        -uu,--uuid <guest UUID>         search for events related to the virtual
                                        machine with the given UUID.
        -v,--version                    version
        -vm,--vm-name <guest name>      search for events related to the virtual
                                        machine with the name.
        -w,--word                       string matches are whole word
        -x,--executable <executable name>  search based on executable name

```
## TIPS

如果需要记录被审计对象被删除事件，则需要审计该对象的上一级目录。

[Monitor/audit file delete on Linux](https://stackoverflow.com/questions/29519590/monitor-audit-file-delete-on-linux)
