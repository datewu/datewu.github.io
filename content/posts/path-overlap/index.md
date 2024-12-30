---
title: "子目录父目录"
description: 两个目录有重叠，则必有一个是另外一个的父目录
date: 2018-09-10T21:20:33+08:00
tags: [
    "python",
]
categories: [
    "开发",
]
cover:
  image: Half-overlapping-paths-of-AB.png
draft: false
---

最近开发的遇到一个需求是在判断 两个目录是否相互包含。

想着用正则表达式或者递归去解决，捣鼓一段时间后发现总有些edge case 不能cover到，

后来发现用 python 的pathlib 可以很好的解决。

```python
from pathlib import Path
def overlapping(a, b):
    if a == b:
        return True
    a_path = Path(a)
    b_path = Path(b)
    return a_path in b_path.parents or b_path in a_path.parents
```
