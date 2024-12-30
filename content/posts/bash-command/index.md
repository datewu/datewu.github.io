---
title: "bash简介"
description: 整理shell脚本中常用命令和函数方法
date: 2021-11-17T10:06:54+08:00
tags: [
    "shell",
    "bash",
    "command",
]
categories: [
    "开发",
    "运维",
]
cover:
  image: terminal.jpeg
draft: flase
---
本文会不定期更新 :)
## set
可以使用set命令改变shell脚本默认的执行流程。
比如 `set -e` 可以使得shell脚本遇到某一条命令出错（ `echo $?` 不为0）时立即退出执行。

```shell
#/bin/bash
set -e
false
echo you cannot see me, unless you comment out the 'set -e' flag, haha
```

[set详细文档](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

## du
```shell
❯ du -sh Downloads 
4.1G    Downloads
```
[wiki](http://zh.wikipedia.org/wiki/Du_%28Unix%29)

## rm
```shell
rm $0  # 删除当前文件 for cleanup
```

## job
### nohup
在后台执行当前命令：
```shell
nohup /usr/sbin/script.sh  &
```
默认情况下，进程是前台进程，这时就把Shell给占据了，我们无法进行其他操作，对于那些没有交互的进程，
我们希望将其在后台启动，可以在启动参数的时候加一个'&'实现这个目的。  

```shell
❯ sleep 5 &
[1] 34769
✦ ❯ 
[1]  + 34769 done       sleep 5
✦ ❯ 
```
进程切换到后台的时候，我们把它称为job。切换到后台时会输出相关job信息，上面&的输出 [1] 34769 ：
[1]表示job ID 是1,11319表示进程ID是34769。切换到后台的进程，仍然可以用ps命令查看。

### fg/bg suspended
可以通过bg <jobid>（background）和fg<jobid>（foreground）命令将其在前后台间状态切换。
可以使用<ctl>+z 组合键把当前fg的进程挂起:
```shell
Source changed "/Users/r/datewu.github.io/content/posts/bash-command/index.md": WRITE
Total in 15 ms
^Z
[1]  + 3595 suspended  hugo server
```
注意，挂起的进程会暂停运行。需要再执行bg/fg命令才能继续运行：
```shell
datewu.github.io on  main [!?] took 7m41s 
✦ ❯ bg
[1]  + 3595 continued  hugo server
```

同样的，bg之后执行fg命令就可以把job重新分配到当前的shell了。
```shell
datewu.github.io on  main [!?] 
✦ ❯ ls
Makefile    Readme.md   archetypes  config.yaml content     data        layouts     resources   static      themes
datewu.github.io on  main [!?] 
✦ ❯ fg
[1]  + 3595 running    hugo server

```

## 守护进程
如果一个进程永远都是以后台方式启动，并且不能受到Shell退出影响而退出，一个正统的做法是将其创建为守护进程。
守护进程值得是系统长期运行的后台进程，类似Windows服务。守护进程信息通过ps –a无法查看到，需要用到–x参数。
当查看守护进程时，往往还附上-j参数以查看作业控制信息，其中TPGID一栏为-1就是守护进程。

```shell
root ~ ps xj
PPID PID PGID SID TTY TPGID STAT UID TIME COMMAND
953 1190 1190 1190 ? -1 Ss 1000 0:00 /bin/sh /usr/bin/startkde
1 1490 1482 1482 ? -1 Sl 1000 0:00 /usr/bin/VBoxClient –seamless
1 1491 1477 1477 ? -1 Sl 1000 0:00 /usr/bin/VBoxClient –display

```
创建守护进程最关键的一步是调用setsid函数创建一个新的Session，并成为Session Leader。
成功创建守护进程的流程为：
1. 创建一个新的Session，当前进程成为Seesion Leader， 当前进程的id就是Session id；
2. 创建一个新的进程组，当前进程成为进程组的Leader， 当前进程的id就是进程组的id；
3. 如果当前进程原本有一个控制终端，则它会失去这个shell，成为一个没有shell的进程（即守护进程）。

可以使用的命令有 `disown setsid nohup`

```shell
❯ tldr disown
Command disown does not exist for the host platform. Displaying the page from linux platform

  disown

  Allow sub-processes to live beyond the shell that they are attached to.
  See also the jobs command.
  More information: https://www.gnu.org/software/bash/manual/bash.html#index-disown.

  - Disown the current job:
    disown

  - Disown a specific job:
    disown %job_number

  - Disown all jobs:
    disown -a

  - Keep job (do not disown it), but mark it so that no future SIGHUP is received on shell exit:
    disown -h %job_number


See also: jobs


~ 
❯ man setsid | head
SETSID(2)                      System Calls Manual                     SETSID(2)

NAME
     setsid – create session and set process group ID

SYNOPSIS
     #include <unistd.h>

     pid_t
     setsid(void);

```

## exit
```shell
#/bin/bash
exit(0) #脚本/命令正常退出
exit(1) # 脚本/命令异常退出
```

## $? && ||
shell 在执行某个命令的时候，会返回一个返回值，该返回值保存在 shell 变量 $? 中。
当 $? == 0 时，表示执行成功；当 $? == 1 时（非0返回值，一般在0-255间），表示执行失败。
shell 提供了 && 和 || 来实现命令执行flow控制的功能，shell 将根据 && 或 || 前面命令的返回值来选择执行后续命令。

### &&
```shell
command1 && command2 [&& command3 ...] 
```
1. 命令之间使用`&&`连接，实现逻辑与的功能；
2. 只有在 `&&` 左边的命令返回真（命令返回值 `$? == 0`），&& 右边的命令才会被执行；
3. 只要有一个命令返回假（命令返回值 `$? == 1`），后面的命令就不会被执行。 即是短路的功能。

### ||
```shell
command1 || command2 [|| command3 ...] 
```
1. 命令之间使用 `||` 连接，实现 逻辑或的功能；
2. 只有在`||`左边的命令返回假（命令返回值 `$? == 1`），`||` 右边的命令才会被执行。这和 c 语言中的逻辑或语法功能相同，即实现defult赋值操作；
3. 只要有一个命令返回真（命令返回值 `$? == 0`），后面的命令就不会被执行。

## $
shell语句变量无需声明，需要引用变量指时， 在变量名前添加$符号即可（有时需要配合括号消除歧义）:
```shell
var=hellhttp://sdf.com?uid=233&pwd=ls
echo var  # var
echo $var  # hellhttp://sdf.com?uid=233&pwd=ls
va=he
echo $valloworld  # 无输出，因为没有valloworld变量
echo ${va}lloworld  # hellworld
```
### $()
先执行括号里面的shell命令，然后把括号里面shell命令的输出做为新的命令去执行。
也可以使用泛引号``。
```shell
❯ echo ls > abc
~/codebase 
❯ $(less abc) # same as `less abc`
abc             gobookIread     jsbook          lol             playaround
~/codebase 
❯ $(cat abc) 
abc             gobookIread     jsbook          lol             playaround
~/codebase 
❯ $(ls) # same as `ls`
zsh: command not found: abc

❯ echo `date`
2021年11月17日 星期三 11时58分02秒 CST
~ 
❯ echo $(date)
2021年11月17日 星期三 11时58分10秒 CST
```

## wget
http basic auth
```shell
wget --no-check-certificate --user user --password pass https://server_address/
```

## curl

```shell
curl -I google.com
curl -i google.com

# Post json file
curl -vX POST http://localhost:9095/post -d @t.json -H "Content-Type: application/json" -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNTUxNDEyODY2LCJleHAiOjE1NTIwMTc2NjZ9.V6ZT8L_r_arIlxtRHul-FxKt4exErTkvNdYy7O_cR5A'
```

## argument
### default argument
```shell
#!/usr/local/bin/bash

echo 'begin'
date
duration=${1-"3"} # default 3
sleep $duration
echo 'finish'
date

#begin
#2021年11月17日 星期三 12时05分52秒 CST
#finish
#2021年11月17日 星期三 12时05分55秒 CST
#~ took 3s 
```

## loop
bash 提供 for和while两种循环控制
### for
```shell
# for in 
for i in abc.s{1..1000}; do
    echo $i
done

# for arguments
./for.sh x y z sdf{1..4} 1 9
#for a; do
#	echo $a
#done
```
### while (read)
```shell
while read -r h; do
 	echo -n $h
done
#❯ bash read-pwds.sh 
#abcde
#abcdexyz
#xyz% 
```

## macos
### osascript

![macos osascript notification](mac.png)
```shell
#!/bin/sh
#
# must use sh for `at` command

#!/usr/bin/osascript
#display notification "Lorem ipsum dolor sit amet" with title "Title"

# https://apple.stackexchange.com/questions/57412/how-can-i-trigger-a-notification-center-notification-from-an-applescript-or-shel/115373#115373
osascript -e 'display notification "吃武汉热干面啦" with title "米西米西" '
```
