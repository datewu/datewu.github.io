---
title: "TCP/IP教程"
description: 翻译tcp/ip入门教程
date: 2020-04-13T22:25:56+08:00
lastmod: 2021-01-13T22:25:56+08:00
tags: [
    "tcp/ip",
    "tutorial",
    "network",
]
categories: [
    "语法",
    "开发",
]
cover:
  image: The-logical-mapping-between-OSI-basic-reference-model-and-the-TCP-IP-stack.png
draft: false
---

本文不定期更新 :)

上个礼拜逛[Hacker News](https://news.ycombinator.com/)看到推荐了一份写于1991年介绍TCP/IP协议的文章[A TCP/IP Tutorial](https://tools.ietf.org/html/rfc1180)。

初略的扫了几眼，发现不错，加入了收藏夹。

昨天晚上抽出时间来细读了一遍觉得很有翻译的价值，于是试着翻译一下：

## Introduction

This tutorial contains only one view of the salient points of TCP/IP,
and therefore it is the "bare bones" of TCP/IP technology.  It omits
the history of development and funding, the business case for its
use, and its future as compared to ISO OSI.  Indeed, a great deal of
technical information is also omitted.  What remains is a minimum of
information that must be understood by the professional working in a
TCP/IP environment.  These professionals include the systems
administrator, the systems programmer, and the network manager.

This tutorial uses examples from the UNIX TCP/IP environment, however
the main points apply across all implementations of TCP/IP.

Note that the purpose of this memo is explanation, not definition.
If any question arises about the correct specification of a protocol,
please refer to the actual standards defining RFC.

The next section is an overview of TCP/IP, followed by detailed
descriptions of individual components.
   
1.  序言

这篇教程只是对 TCP/IP 协议中一些最重要的要点做描述性的介绍，因此可以把这篇教程看作是TCP/IP 技术的骨架。
这篇教程**不涉及** TCP/IP 的发展历史，资金/资助来源，商业用途以及和ISO OSI的对比来看TCP/IP的未来会怎样。而且很多详细的技术细节也不会在本文中得到介绍。
这篇教程所**涉及**的内容，恰恰是一个日常工作在TCP/IP 环境的专业人士**必须**理解的**最少**TCP/IP技术信息量，不能再少了。这些专业人士包括了系统管理员，系统程序员，和网络管理员。
这篇教程使用的例子都是在 UNIX TCP/IP 环境，但是这些例子所表达的主要意思对所有实现了TCP/IP协议的环境来说都是同样试用的。

**注意**⚠️ 这篇教程的目的是解释/介绍 TCP/IP技术，并不是给TCP/IP 技术下定义。

如果读者对这篇教程描述的某个协议的规格/规范产生了疑问，请参考这个协议的RFC具体的规范定义。
下个小节是对 TCP/IP技术的概览，然后是单独的对每个TCP/IP组件详细的描述。

 

## TCP/IP Overview

The generic term "TCP/IP" usually means anything and everything
related to the specific protocols of TCP and IP.  It can include
other protocols, applications, and even the network medium.  A sample
of these protocols are: UDP, ARP, and ICMP.  A sample of these
applications are: TELNET, FTP, and rcp.  A more accurate term is
"internet technology".  A network that uses internet technology is
called an "internet".
   
2. TCP/IP 概览

术语“TCP/IP”一般意义上来说，通常是指 任何以及所有和 ‘TCP 协议’，与 ‘IP 协议’有关的技术。 “TCP/IP”术语可以指 其它的网络协议，网络应用，甚至是物理网络媒介。这些网络协议可以是：UDP, ARP, 和 ICMP； 网络应用可以是：TELNET，FTP，和 RCP。

“TCP/IP”更准确的术语应该是“互联网技术”。当一个网络使用了互联网技术，我们就可以把这个网络叫“互联网”。

 

### Basic Structure

To understand this technology you must first understand the following
logical structure:
```yaml
             ----------------------------
             |    network applications  |
             |                          |
             |...  \ | /  ..  \ | /  ...|
             |     -----      -----     |
             |     |TCP|      |UDP|     |
             |     -----      -----     |
             |         \      /         |
             |         --------         |
             |         |  IP  |         |
             |  -----  -*------         |
             |  |ARP|   |               |
             |  -----   |               |
             |      \   |               |
             |      ------              |
             |      |ENET|              |
             |      ---@--              |
             ----------|-----------------
                       |
 ----------------------o---------
     Ethernet Cable

          Figure 1.  Basic TCP/IP Network Node

```
This is the logical structure of the layered protocols inside a
computer on an internet.  Each computer that can communicate using
internet technology has such a logical structure.  It is this logical
structure that determines the behavior of the computer on the
internet.  The boxes represent processing of the data as it passes
through the computer, and the lines connecting boxes show the path
of data.  The horizontal line at the bottom represents the Ethernet
cable; the "o" is the transceiver.  The "*" is the IP address and the
"@" is the Ethernet address.  Understanding this logical structure is
essential to understanding internet technology; it is referred to
throughout this tutorial.
   
   
2.1 基础结构

 要想理解TCP/IP技术，首先你**必须**要理解下面图表展示的网络节点逻辑结构：

```yaml
            ----------------------------
            |         网络应用          |
            |                          |
            |...  \ | /  ..  \ | /  ...|
            |     -----      -----     |
            |     |TCP|      |UDP|     |
            |     -----      -----     |
            |         \      /         |
            |         --------         |
            |         |  IP  |         |
            |  -----  -*------         |
            |  |ARP|   |               |
            |  -----   |               |
            |      \   |               |
            |      ------              |
            |      |ENET|              |
            |      ---@--              |
            ----------|-----------------
                      |
----------------------o---------
        以太网网线

         图1.  基础TCP/IP网络节点逻辑结构
  
  ```
   
上图（图1）描绘的是互联网上某台计算机节点内部网络协议的逻辑分层架构。每一台能使用互联网技术和其它计算机通信的计算机都有图1描述的逻辑结构。图1描述的逻辑结构也决定了互联网上计算机的行为。

图1中的 虚线框 表示当数据在计算机内部传输时 对数据的某种处理， 连接虚线框的虚线表示数据在计算机内部传输的路径。最下面的那条虚线表示以太网线；“o”表示接收发送器， “*”表示IP 地址，“@”表示 以太（MAC）地址。


理解图1所描述的逻辑结构的对理解整个互联网技术起着关键性作用；而且对图1的引用贯穿了整篇教程。
   
    


### Terminology

The name of a unit of data that flows through an internet is
dependent upon where it exists in the protocol stack.  In summary: if
it is on an Ethernet it is called an Ethernet frame; if it is between
the Ethernet driver and the IP module it is called a IP packet; if it
is between the IP module and the UDP module it is called a UDP
datagram; if it is between the IP module and the TCP module it is
called a TCP segment (more generally, a transport message); and if it
is in a network application it is called a application message.

These definitions are imperfect.  Actual definitions vary from one
publication to the next.  More specific definitions can be found in
RFC 1122, section 1.3.3.

A driver is software that communicates directly with the network
interface hardware.  A module is software that communicates with a
driver, with network applications, or with another module.

The terms driver, module, Ethernet frame, IP packet, UDP datagram,
TCP message, and application message are used where appropriate
throughout this tutorial
   
 2.2 术语
 
根据数据在图1中被哪一层逻辑层处理，我们给每层的数据块起了不同的名字加以区分。

总的来说，如果数据块在以太网上，那么这个数据块就被称为 'Ethernet frame'；
如果数据块
