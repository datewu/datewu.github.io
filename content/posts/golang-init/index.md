---
title: init优先级
description: 减少在init()函数初始化全局变量
date: 2018-01-23T16:23:01+08:00
tags: [
    "golang",
    "init",
    "global",
]
categories: [
    "开发",
]
cover:
  image: init.png
draft: false
---

假设一个golang项目的三个源文件`a.go`,`b.go`, `c.go`，都定义了`function inint(){}`函数，

其中`c.go`文件初始化了一个全局变量`globalVar`，同时`a.go` 或者`b.go`的`init func` 引用了这个全局变量`globalVar`。

那么这个时候就会出现一个问题，在`a.go`和 `b.go`的init func中 `globalVar`的引用是空值。

## 示例

### 文件结构

```shell
❯ tree
.
├── a.go
├── b.go
├── c.go
├── go.mod
└── main.go

0 directories, 5 files
```

### 源代码
```golang

// file `a.go`
package main

import "fmt"

func init() {
        // globalVar is empty
        fmt.Println("globalVar in a.go:", globalVar)
}

// file `b.go`
package main

import "fmt"

func init() {
        // globalVar is empty
        fmt.Println("globalVar in b.go:", globalVar)
}


// file `c.go`
package main

import (
        "fmt"
        "time"
)

func init() {
        globalVar = initVar()
        fmt.Println("globalVar in c.go:", globalVar)
}

func initVar() string {
        time.Sleep(20 * time.Millisecond)
        return "late is better than never"
}

// file `main.go`
package main

import "fmt"

var globalVar = ""

func main() {
        fmt.Println("vim-go")
}
```

### result
```shell
❯ go build -o demo
❯ ./demo 
globalVar in a.go: 
globalVar in b.go: 
globalVar in c.go: late is better than never
vim-go
```

## 解决办法

简单的解决办法可以是重命名`c.go`为`0a.go`保证`0a.go`中的`init`最早执行完成，

```shell
mv c.go 01.go
```
这个解决方案的优点是可以不用修改代码，但是不够优雅。

比较好的解决方式应该是，不要在`init func`里初始化全局变量，应该直接在`top block context`中对全局变量初始化：

```golang
// file `c.go`
package main

var globalVar = initVar()

func init() {
    // ...
}

```
