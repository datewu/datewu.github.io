---
title: 排列组合
description: 使用递归从数组里选取长度为m的子数组
date: 2021-12-13T11:34:08+08:00
tags: [
    "golang",
    "math",
    "recursion",
]
categories: [
    "开发",
]
cover:
  image: permutation-combinnaiton.webp 
draft: false
---

上礼拜有人问我，如何从数组中选择和为n，长度为m的所有的子数组？
## 问题
### 输入
`a = []int{10, 7, -5, 4, 8, 16, 70, -30, 91}`

`m = 3, n = 15`
### 输出
```golang
[[10 35 -30] [-5 4 16]]
```

## 答案

### 算法
这是一个典型的排列组合的问题，只要把`Cn`算出来然后做过滤就好，核心是数组组合的算法。

我使用的是递归算法：
1. 选取包含第一个元素的组合：拼接第一个元素和剔除第一个元素后数组的所有的`m-1`的组合；
2. 选取不含第二个元素的长度为`m`的组合；
3. 将上面两个组合合并起来即可；（不用去重，因为没有重复的）
4. 递归结束条件：当`m=1`的时候，直接放回所有数组元素；当`m=len(input)`时，直接返回`[][]int{input}`；当`m>len(input)`时，返回空；

### golang实现
```golang
package main

import (
	"flag"
	"fmt"
)

var (
	size = flag.Int("size", 3, "size of array")
	sum  = flag.Int("sum", 0, "sum of two numbers")
)

func main() {
	flag.Parse()
	input := []int{10, 7, -5, 4, 8, 16, 35, -30, 91}
	// for _, v := range chooseM(input, 8) {
	// 	fmt.Println(v)
	// }
	fmt.Println(input)
	fmt.Println(chooseSumN(input, *size, *sum))
}

func chooseM(data []int, m int) [][]int {
	if len(data) < m {
		return nil
	}
	if len(data) == m {
		return [][]int{data}
	}
	if m == 1 {
		var res [][]int
		for _, v := range data {
			res = append(res, []int{v})
		}
		return res
	}
	one := [][]int{}
	rest := chooseM(data[1:], m-1)
	for _, v := range rest {
		m := append([]int{data[0]}, v...)
		one = append(one, m)
	}

	return append(one, chooseM(data[1:], m)...)
}

func chooseSumN(data []int, m, n int) [][]int {
	out := [][]int{}
	for _, v := range chooseM(data, m) {
		sum := 0
		for _, i := range v {
			sum += i
		}
		if sum == n {
			out = append(out, v)
		}
	}

	return out
}
```

### 调试输出
```fish
❯ ./c3 -sum 15 -size 2
[10 7 -5 4 8 16 35 -30 91]
[[7 8]]

❯ ./c3 -sum 15        
[10 7 -5 4 8 16 35 -30 91]
[[10 35 -30] [-5 4 16]]
```

## 工程优化
上面是算法的解释，工程实现的时候可以把`选择`和`过滤`结合在一起做，提升代码的时间/空间性能。

### golang实现
```golang
func engineer(data []int, m, n int) [][]int {
	if len(data) < m {
		return nil
	}
	if len(data) == m {
		sum := 0
		for _, v := range data {
			sum += v
		}
		if sum == n {
			return [][]int{data}
		}
		return nil
	}
	if m == 1 {
		var res [][]int
		for _, v := range data {
			if v == n {
				res = append(res, []int{v})
			}
		}
		return res
	}
	one := [][]int{}
	rest := engineer(data[1:], m-1, n-data[0])
	for _, v := range rest {
		m := append([]int{data[0]}, v...)
		one = append(one, m)
	}

	return append(one, engineer(data[1:], m, n)...)
}

```
