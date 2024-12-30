---
title: perm函数
description: 随机排列
date: 2021-12-28T10:28:03+08:00
tags: [
    "golang",
]
categories: [
    "开发",
]
cover:
  image: permutation.png
draft: false
---

工作上遇到一个问题，好奇goalng的排列数`Perm`是怎么实现的，看了下源代码，写的很简洁。

使用了随机交换算法来得到一个排列组合。


```fish
package rand // import "math/rand"

func Perm(n int) []int
    Perm returns, as a slice of n ints, a pseudo-random permutation of the
    integers in the half-open interval [0,n) from the default Source.


```
### 交换

本质上说就是交换`m[i]`和`m[j]`，且`i> j`。 
```golang
func Perm(n int) []int {
	m := make([]int, n)
	for i := 0; i < n; i++ {
		j := rand.Intn(i + 1)
        // std implement
		// m[i] = m[j]
		// m[j] = i

		// swap
		m[i], m[j] = m[j], i

        // same effect
		// m[i] = i
		// m[i], m[j] = m[j], m[i]
	}
	return m
}

```

