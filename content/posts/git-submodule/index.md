---
title: "清理git submodule"
description: 丢弃本地git submodule的修改
date: 2021-11-16T16:13:57+08:00
tags: [
    "git",
    "makefile",
]
categories: [
    "开发",
]
cover:
  image: git-submodule.png
draft: false
---

当我们本地对git的submodule目录下的文件做了改动时，会发现不论是用`git checkout .`
还是 `git clean -df`都无法丢弃修改。使用`git status`命令查看工作树的状态时会有如下
报错信息`git submodule modified content`

## 错误

以hugo为例，当使用`hugo server`本地预览博客文章时， hugo会修改主题目录的内容。从而出现 git submodule modified content的问题。

```shell
❯ git status
位于分支 main
您的分支领先 'origin/main' 共 1 个提交。
  （使用 "git push" 来发布您的本地提交）

尚未暂存以备提交的变更：
  （使用 "git add <文件>..." 更新要提交的内容）
  （使用 "git restore <文件>..." 丢弃工作区的改动）
  （提交或丢弃子模组中未跟踪或修改的内容）
        修改：     themes/stack (修改的内容)

修改尚未加入提交（使用 "git add" 和/或 "git commit -a"）

```
这个问题挺常见的，Google后使用下面两条命令即可清理submodule：
## meat
```shell
git submodule foreach --recursive git reset --hard
git submodule update --recursive --init
```
[How do I revert my changes to a git submodule?](https://stackoverflow.com/a/44669463)

### make
建议在根目录下编写内容如下的`Makefile`， 以节省输入命令的时间和加强记忆。
```makefile
.PHONY: clean
clean:
	-@git submodule deinit -f .
	-@git submodule update --init --recursive
#git submodule deinit -f .
#git submodule update --init

```

执行`make`命令即可清除本地对git submodule的改动。

```shell
❯ make
已清除目录 'themes/stack'
子模组 'themes/stack'（https://github.com/datewu/hugo-theme-stack.git）未对路径 'themes/stack' 注册
子模组 'themes/stack'（https://github.com/datewu/hugo-theme-stack.git）已对路径 'themes/stack' 注册
子模组路径 'themes/stack'：检出 'aeb077874a7de9ce71304c990ad5cfdc72664f38'

```
