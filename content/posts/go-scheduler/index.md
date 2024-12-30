---
title: 用户线程调度模型
description: Go runtime调度模型简介
date: 2021-11-19T14:44:20+08:00
tags: [
    "golang",
    "senior",
    "scheduler",
    "runtime",
]
categories: [
    "开发",
]
cover:
  image: go-scheduler.png
draft: false
---

一般来说多线程3种并发模型：
1. N:1， 把n个用户线程（Green threed）映射到一个操作系统的线程（OS Threed）上。

这种模型的优点是 用户线程之间的上下文切换（context switch）会非常快，
缺点是不能充分的运用多核CPU资源（一个OS Thread只能在一个CPU上）；
2. 1:1， 每个用户线程映射到一个操作系统线程上。

这种和第一种的优缺点正好相反。1:1 可以充分利用多核处理器资源，但是上下文切换很慢。

3. M:N，把M个用户线程映射到N个操作系统线程上。

这种结合了前面两种模型的优点，同时规避了他们的缺点。

## M/G/P
golang runtime主要通过抽象出Machine/Processor/Groutine三种对象，和一些算法(steal)实现了M:N模型。

### Machine
M对应操作系统线程，代表被操作系统管理的线程资源。

### Goroutine
G对应用户线程（Goroutine），包含了stack，`指令指针`，还有一些会影响这个Goroutine调度的关键信息，比如有关的channel。

### Processor
P对应本地逻辑调度器上下文（context），是调度算法具体的执行对象，主要用来处理`steal`和`hand-off`等算法。

## demo
### normal
![Machine Processor Groutine demo](in-motion.jpeg)
上图中，我们有2个M(OS Thread)，每个M都有一个本地的context（P），都在运行一个goroutine（G）。

有几点需要说明一下：
1. M**必须**得到一个P**才能**运行goroutine里面的指令；
2. P的数量等于环境变量`GOMAXPROCS`的值， 一般等于宿主机的处理器核心数；
3. 灰色的goroutine没有在`running`，但是已经准备好被调度了。他们所处的队列叫`runqueues`，每当执行的`go statement`指令时，新的goroutine就会加到runqueue的尾部；
4. 每个P都有自己本地runqueue。

### (sys)call / hand-off
![syscall demo](syscall.jpeg)

`M0`把自己的context给了`M1`，流程是这样的：
1. M0执行G0上的某条`syscall`指令；
2. M0放弃P进入block状态，M1得到并继续执行P调度算法，可能去执行另外某一个goroutine；
3. `syscall`返回，M0因为没有P所以不能继续执行G0。现在M0需要去偷一个P执行G0，否则就把G0放到`global runqueue`里面然后把自己放回thread cahe去sleep。

也有几点需要单独说明：
1. M1可能是scheduler为了处理syscall特意创建的，也可能是来自`thread cache`；
2. 当P本地的runqueue为空时，P会从`global runqueue`拉取G；即使本地runqueue没有空，P也会定期的检查`global runqueue`里的goroutine。
3. 正是因为要处理`syscal/hand-off`，所以即使GOMAXPROCS等于1，Go还是会启动多个OS线程。

### stealing work
![steal work/goroutine demo](steal.jpeg)

当P自己本地的runqueue空了，而且global runqueue也是空的时候，
P就会去其他P偷掉对方一半的G，从而使得自己和其它P都能高效工作，提高整体性能。
 
[参考文档](https://morsmachine.dk/go-scheduler)
