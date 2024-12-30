---
title: 事件驱动
description: shell脚本中如何避免轮询
date: 2018-06-27T12:20:29+08:00
tags: [
    "shell",
    "consumer",
    "producer",
]
categories: [
    "开发",
]
cover:
  image: pm.png
draft: false
---

在shell脚本里使用`mkfifo`命令创建`named pipes`可以实现简单的事件驱动，
避免poll（轮询）带来的时延（not real-time）和资源消耗的问题。

## mkfifo
```shell
❯ man mkfifo | head -n 12
MKFIFO(1)                    General Commands Manual                   MKFIFO(1)

NAME
     mkfifo – make fifos

SYNOPSIS
     mkfifo [-m mode] fifo_name ...

DESCRIPTION
     mkfifo creates the fifos requested, in the order specified.  By default,
     the resulting fifos have mode 0666 (rw-rw-rw-), limited by the current
     umask(2).
~ 
```

### consumer
消费者以blocked的状态监听`事件的发生`，然后`handle`:

```shell
#!/bin/bash

pipe=/tmp/testpipe

trap "rm -f $pipe" EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

while true
do
    if read line <$pipe; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi
        echo $line
    fi
done

echo "consumer exiting"
```

### producer
生产者往`pipe`里写入内容，`触发事件`：
```shell
#!/bin/bash

pipe=/tmp/testpipe

if [[ ! -p $pipe ]]; then
    echo "Reader not running"
    exit 1
fi

msg=${1-"Hello from $$"}

echo $msg >$pipe
```

