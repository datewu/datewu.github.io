---
title: 循环播放gif图片
description: 循环播放不循环的gif图片，或者关闭无限循环的gif图片
date: 2021-11-18T17:23:48+08:00
tags: [
    "imageMagick",
    "gif",
    "command",
]
categories: [
    "运维",
]
cover:
  image: deja-vu-brain-injury.jpeg
draft: false
---

## install
首先使用`macport`安装 `imagemagick`软件包，因为macport是编译安装软件包，所以安装过程会比较久（~9min）。
更加习惯homebrew的可以参考 [官网imagemagick download](https://imagemagick.org/script/download.php#macosx) 安装。
```shell
❯ sudo port install imagemagick                                                                                                                                                     
Password:                                                                                                                                                                           
--->  Computing dependencies for ImageMagickWarning: cltversion: The Command Line Tools are installed, but MacPorts cannot determine the version.                                   
Warning: cltversion: For a possible fix, please see: https://trac.macports.org/wiki/ProblemHotlist#reinstall-clt

The following dependencies will be installed:  
 aom
 brotli
 ....
 ....
 .
 .
--->  Activating webp @1.2.1_0
--->  Cleaning webp
--->  Fetching archive for ImageMagick
--->  Attempting to fetch ImageMagick-6.9.11-60_1+x11.darwin_21.x86_64.tbz2 from https://packages.macports.org/ImageMagick
--->  Attempting to fetch ImageMagick-6.9.11-60_1+x11.darwin_21.x86_64.tbz2 from https://pek.cn.packages.macports.org/macports/packages/ImageMagick
--->  Attempting to fetch ImageMagick-6.9.11-60_1+x11.darwin_21.x86_64.tbz2 from https://kmq.jp.packages.macports.org/ImageMagick
--->  Fetching distfiles for ImageMagick
--->  Attempting to fetch ImageMagick-6.9.11-60.tar.xz from https://distfiles.macports.org/ImageMagick
--->  Verifying checksums for ImageMagick     
--->  Extracting ImageMagick
--->  Configuring ImageMagick
--->  Building ImageMagick                    
--->  Staging ImageMagick into destroot       
--->  Installing ImageMagick @6.9.11-60_1+x11 
--->  Activating ImageMagick @6.9.11-60_1+x11 
--->  Cleaning ImageMagick
--->  Updating database of binaries
--->  Scanning binaries for linking errors
--->  No broken files found.                  
--->  No broken ports found.
~ took 8m49s 

```
## convert
修改gif循环次数，当`loop为0`时则关闭了gif的循环播放。
```shell
# convert -h | grep loop
#  -loop iterations     add Netscape loop extension to your GIF animation
convert -loop 1000 dog.gif bad_dog.gif
```
