---
title: 记一次overflow
description: 牢记先转换再计算
date: 2023-02-27T10:57:27+08:00
lastmod: 2023-02-28T10:07:27+08:00
tags: [
    "golang",
    "gotcha",
]
categories: [
    "开发",
]
cover:
  image: overflow.png
draft: false
---

最近给一个项目加上了限速的功能，跑了一段时间后发现一个问题，超级管理员的速度阈值本来是最大的，实际使用是却发现好想是0。

打了个个断点， 发现admin的rate.Limit 确实是 -1000。


看了下代码，原来是overflow了。 
```golang
-       limit := rate.NewLimiter(rate.Limit(q.Speed*1000), 1000)                              
+       limit := rate.NewLimiter(rate.Limit(float64(q.Speed)*1000), 1000)  
```

`q.Speed` 的type是 `int16`

当时写的时候觉得`float64`怎么可能overflow， 现在发现 是`int16 * 1000`就已经overflow了。

所以类型转换的时候一定要先转换再计算。


## update

如果是`int64` 转 `int32` 的话，则应该反过来： `int32(a / 1000)` 其中a是`int64`类型。

准确来说，小转大，先转换再计算； 大转小，先计算再转小。

