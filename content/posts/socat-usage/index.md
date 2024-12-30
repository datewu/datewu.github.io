---
title: "socat工具"
description: 简单介绍socat端口转发命令
date: 2020-04-14T09:50:07+08:00
tags: [
    "linux",
    "socat",
    "port forward",
    "relay",
]
categories: [
    "运维",
]
cover:
  image: socat.jpeg
draft: false
---


众所周知kubenetest的端口转发功能[kubectl port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/#forward-a-local-port-to-a-port-on-the-pod)非常实用，可以提高开发人员的debug效率。

其实`kubectl port-forward`的底层脏活累活都是`socat`命令在做，`kubectl`只能算是一个代理商。

## socat

### 端口转发

`socat tcp-listen:58812,reuseaddr,fork tcp:localhost:8000`把58812端口的流量转发到 8000上。

```bash
bash-5.1# python3 -m http.server &

bash-5.1# socat tcp-listen:58812,reuseaddr,fork tcp:localhost:8000 &

bash-5.1# curl -I localhost:58812
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.10.3
Date: Thu, 14 Apr 2022 03:19:15 GMT
Content-type: text/html; charset=utf-8
Content-Length: 336

```


从而使得原来无法访问的 `localhost:8000`端口的服务，现在可以通过`*:58812`访问到了。

```bash
bash-5.1# netstat -nlp 
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:58812           0.0.0.0:*               LISTEN      10/socat
tcp        0      0 0.0.0.0:8000            0.0.0.0:*               LISTEN      31/python3
Active UNIX domain sockets (only servers)
Proto RefCnt Flags       Type       State         I-Node PID/Program name    Path

```
### 其他
```bash
➜  ~ tldr socat

socat

Multipurpose relay (SOcket CAT).

- Listen to a port, wait for an incoming connection and transfer data to STDIO:
    socat - TCP-LISTEN:8080,fork

- Create a connection to a host and port, transfer data in STDIO to connected host:
    socat - TCP4:www.example.com:80

- Forward incoming data of a local port to another host and port:
    socat TCP-LISTEN:80,fork TCP4:www.example.com:80
```

## 语法

[man 手册](https://linux.die.net/man/1/socat)
> Socat is a command line based utility that establishes two bidirectional byte streams and transfers data between them. Because the streams can be constructed from a large set of different types of data sinks and sources (see address types), and because lots of address options may be applied to the streams, socat can be used for many different purposes.

> Filan is a utility that prints information about its active file descriptors to stdout. It has been written for debugging socat, but might be useful for other purposes too. Use the -h option to find more infos.

> Procan is a utility that prints information about process parameters to stdout. It has been written to better understand some UNIX process properties and for debugging socat, but might be useful for other purposes too.

> The life cycle of a socat instance typically consists of four phases.

> In the init phase, the command line options are parsed and logging is initialized.

> During the open phase, socat opens the first address and afterwards the second address. These steps are usually blocking; thus, especially for complex address types like socks, connection requests or authentication dialogs must be completed before the next step is started.

> In the transfer phase, socat watches both streamscq read and write file descriptors via CWselect() , and, when data is available on one side and can be written to the other side, socat reads it, performs newline character conversions if required, and writes the data to the write file descriptor of the other stream, then continues waiting for more data in both directions.

> When one of the streams effectively reaches EOF, the closing phase begins. Socat transfers the EOF condition to the other stream, i.e. tries to shutdown only its write stream, giving it a chance to terminate gracefully. For a defined time socat continues to transfer data in the other direction, but then closes all remaining channels and terminates.

