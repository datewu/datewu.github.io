---
title: "调试golang测试"
description: 确定继续执行吗？
date: 2020-10-14T18:38:01+08:00
tags: [
    "golang",
    "block",
    "approve",
]
categories: [
    "开发",
    "测试",
]
cover:
  image: ta_moderationworkflow.png
draft: false
---

调试某个go test程序的时候，需要实现`confirm/approve`功能:

> 测试完`testCase1`之后（或者说是某个断点），用户输入`yes`，执行下一个`case`，输入`no`， 则退出整个测试。

## 分析
下意识的觉得这个很好实现，调用`fmt.Scan`应该就OK了。

但是写的时候才发现，`go test` 会强制重定向`os.Stdin = /dev/null`忽略所有的 stdin输入，

所以没法使用 `fmt.Scan`来等待键盘(用户)的输入：
```golang
// fmt.Scan reads from os.Stdin, which is set to /dev/null when testing.
// Tests should be automated and self-contained anyway, so you don't want
// to read from stdin.
// Either use an external file, a bytes.Buffer, or a strings.Reader and
// call scan.Fscan if you want to test **the literal** `scan` Function.
```

## 解决方案
可以[参考事件驱动](/posts/shell-fifo/)，使用`named pipes`来实现`confirm/approve`功能：

### 消费者
先写一个消费者的函数`readPipe`：
```golang
package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
)

func main() {

    for i := 0; i < 6; i++ {
        readPipe(i)
    }
}

func readPipe(i int) {
    f, err := os.Open("pipe")
    if err != nil {
        log.Fatalln(err)
    }
    defer f.Close()
    reader := bufio.NewScanner(f)
    for reader.Scan() {
        fmt.Println(i, reader.Text())
    }
}

```
然后在测试的case里调用`readPipe`函数：
```golang
package main

import (
    "fmt"
    "testing"
)

func TestCase1(t *testing.T) {
    fmt.Println("testing  test case 1")

    fmt.Println("test case 1 tested")
    readPipe(1)
}

func TestCase2(t *testing.T) {
    fmt.Println("testing  test case 2")

    fmt.Println("test case 2 tested")
    readPipe(2)
}

func TestCase3(t *testing.T) {
    fmt.Println("testing  test case 3")

    fmt.Println("test case 3 tested")
    readPipe(3)
}

```

### 生成者
创建`pipe`，然后往pipe里写数据，就可以触发(`unblock`)消费者进程。

```bash
➜  ~ mkfifo pipe
➜  ~ ls -alh pipe
prw-r--r--  1 r  staff     0B  4 24 16:32 pipe

```

写入数据：
```bash
➜  ~ date > pipe
➜  ~ date > pipe
➜  ~ date > pipe
```

## 测试
调试的结果如下：
```bash
➜  ~ go test   
testing  test case 1
test case 1 tested
1 2020年 4月24日 星期五 16时31分50秒 CST
testing  test case 2
test case 2 tested
2 2020年 4月24日 星期五 16时31分59秒 CST
testing  test case 3
test case 3 tested
3 2020年 4月24日 星期五 16时32分08秒 CST
PASS
ok      abc     36.016s
```
