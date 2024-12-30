---
title: "vscode按键调整"
description: 默认按住j不放不会连续输入j
date: 2021-05-09T19:25:25+08:00
tags: [
    "vscode",
    "vim",
]
categories: [
    "开发",
]
cover:
  image: vim-jkhl.png
draft: false
---

今天发现`vscodevim`插件不能连续输入方向键`j`， 以为是插件的问题，关闭了插件。

发现在`vscode`里按住`j`不放，编辑器并不会连续输入`j`。

需要调整系统的`dafaults`关闭`PressAndHold`选项：

[enable key-repeating](https://github.com/VSCodeVim/Vim/blob/master/README.md#mac)

> To enable key-repeating, execute the following in your Terminal, log out and back in, and then restart VS Code:

```shell
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false  # Enable key-repeating for vs code
```
