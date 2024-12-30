---
title: "更换brew源"
description: 使用清华的brew repo镜像源
date: 2020-08-14T11:33:00+08:00
tags: [
    "brew",
    "mirrors",
    "cdn",
]
categories: [
    "运维",
]
cover:
  image: homebrew-social-card.png
draft: false
---

国内网络环境日益恶劣，执行`brew update/upgrade`花费的时间够我泡好一壶普洱茶。

不过好景不长，谁能想到那么大的普洱茶饼，日积月累一点点的被我喝完了。

哎，怀恋普洱茶呀。 没了普洱茶，我决定换了brew的官方源，给自己节约节约生命。


## 解决方案
挑挑拣拣一圈之后，我决定使用清华大学开源软件镜像站]的brew源。

按照[官网的](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)指引很快就换好了repo，效果很好。

和[设置macos DNS servers](/posts/macos-dns/)一样我也整理了个shell脚本：

```bash
#!/usr/local/bin/bash
set_qh() {
    git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    
    brew update
}


# revocer
recover() {
    git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew.git
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git
    git -C "$(brew --repo homebrew/cask)" remote set-url origin https://github.com/Homebrew/homebrew-cask.git
    
    brew update
}

a=${1-"check"} # default to check
if [ $a = "r" ]; then
    recover
fi

if [ $a = "set" ]; then
    set_qh
fi

if [ $a = "check" ]; then
    echo "goping to EXPORT HOMEBREW_BOTTLE_DOMAIN"
    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
    echo $HOMEBREW_BOTTLE_DOMAIN
    brew config | grep ORIGIN
    brew update
    brew upgrade
    brew cleanup
fi

echo ""
echo $a successed!

```

上面的bash脚本支持3个参数 `check`,`set`和 `recover`，默认使用 `check`参数。

保存为`set-brew-repo.sh`文件，再加上可执行权限即可：

```bash
➜  ~ chmod +x set-brew-repo.sh
➜  ~ ./set-brew-repo.sh
```
