---
title: 合并图片
description: 使用imageMagick垂直合并多张图片
date: 2021-12-05T11:34:06+08:00
tags: [
    "imageMagick",
    "jpeg",
]
categories: [
    "开发",
]
cover:
  image: imagemagick.jpeg
draft: false
---

填写某政府表格时候，需要把多个图片合并为一张图片。
用`Photoshop`应该很好解决，但是本地没有安装。于是网上查了一下用`imageMagick`也可以解决。


![append two picture ](append.png)

### meat

[Appending images vertically in ImageMagick](https://superuser.com/questions/316132/appending-images-vertically-in-imagemagick/316189)

```shell
# vertical stacking (top to bottom):
convert -append 1.jpeg 2.jpeg 3.jpeg out.jpg

# horizontal stacking (left to right):
convert +append 1.jpg 2.jpg out.jpg
```

### ps

另外这篇[循环播放gif图片](/posts/gif-loop/)也用到了`imageMagick`。
