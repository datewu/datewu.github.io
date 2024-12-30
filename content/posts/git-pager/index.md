---
title: 分页打印日志
description: 配置git log pager
date: 2018-04-14T10:38:59+08:00
tags: [
    "git",
    "log",
]
categories: [
    "开发",
]
cover:
  image: pager.jpeg
draft: false
---

默认配置命令`git log`会在新的窗口打印日志内容，需要敲一下键盘`q` 才能返回当前目录，不方便连续查看:
```shell
➜  lgthw_orign git:(otherbranch) git log --oneline --decorate --all --graph

## NOTE content below will be displayed on new window/buff
* 40303b7 (HEAD -> otherbranch) thirdcommit
| * 3e6e2f7 (master) secondcommit
|/
* f40475e (tag: firstcommittag) firstcommit
(END)
## press `q` to exist

➜  lgthw_orign git:(master) git log --no-pager                        
fatal: unrecognized argument: --no-pager
```

可以把默认的分页改为`inline`模式，可以更快的查看连续的日志：
## meat
```shell
# use --no-pager options
# or set pager to cat
git config --global core.pager cat
# or set pager to less
# git config --global core.pager "less -erX"
```

### demo
```shell
➜  lgthw_orign git:(master) git log --oneline --decorate --all --graph
* f40475e (HEAD -> master) firstcommit
➜  lgthw_orign git:(master) git branch otherbranch
➜  lgthw_orign git:(master) git tag firstcommittag
➜  lgthw_orign git:(master) git log --oneline --decorate --all --graph
* f40475e (HEAD -> master, tag: firstcommittag, otherbranch) firstcommit
➜  lgthw_orign git:(master) date >> afile
➜  lgthw_orign git:(master) ✗ git commit -am secondcommit
[master 3e6e2f7] secondcommit
 1 file changed, 1 insertion(+)
 ➜  lgthw_orign git:(master) git checkout .
 ➜  lgthw_orign git:(master) git log --oneline --decorate --all --graph
 * 3e6e2f7 (HEAD -> master) secondcommit
 * f40475e (tag: firstcommittag, otherbranch) firstcommit
 ➜  lgthw_orign git:(master) git checkout otherbranch
 Switched to branch 'otherbranch'
 ➜  lgthw_orign git:(otherbranch) git log --oneline --decorate --all --graph
 * 3e6e2f7 (master) secondcommit
 * f40475e (HEAD -> otherbranch, tag: firstcommittag) firstcommit
 ➜  lgthw_orign git:(otherbranch) date >> afile
 ➜  lgthw_orign git:(otherbranch) ✗ git commit -am thirdcommit
 [otherbranch 40303b7] thirdcommit
  1 file changed, 1 insertion(+)
  ➜  lgthw_orign git:(otherbranch) git log --oneline --decorate --all --graph
  * 40303b7 (HEAD -> otherbranch) thirdcommit
  | * 3e6e2f7 (master) secondcommit
  |/
  * f40475e (tag: firstcommittag) firstcommit
```

### 参考
[Changing the Display of Git Log](http://blog.timlockridge.com/blog/2013/01/22/changing-the-display-of-git-log/)

>  FYI, `cat` is not the ideal pager for me, since it displays the full git log from the beginning if I don't append a -1 in the end of the command.
`more` was not a good candidate either, since colors was not well displayed in the console with `more`
I preferred to keep `less` as the pager, but display content in the console.
So for me :
git config --global core.pager "less -erX"
(important option here is the -X option)

