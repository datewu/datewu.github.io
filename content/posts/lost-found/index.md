---
title: "mysql空磁盘挂卷问题"
description: 忽略lost+found文件
date: 2022-05-11T14:19:55+08:00
lastmod: 2022-05-11T14:19:55+08:00
tags: [
    "kubernetes",
    "volume",
    "mysql 5.7",
]
categories: [
    "运维",
]
cover:
  image: lostfoundmysql.png
draft: false
---

今天在tke上部署mysql pod，以为很简单。结果发现pod一直crash，查看日志发现是挂卷的问题：
`[ERROR] --initialize specified but the data directory has files in it. Aborting.`

解决办法很简单，给mysql加上启动参数`--ignore-db-dir=lost+found`即可。

[mysql 5.7](https://stackoverflow.com/a/66297627)

### k8s
```yaml
name: mysql-master
image: mysql:5.7
args:
  - "--ignore-db-dir=lost+found"
```


### docker compose
```yaml
version: '3'
services:
  mysql-master:
    image: mysql:5.7
    command: [--ignore-db-dir=lost+found]
    environment:
      - MYSQL_ROOT_PASSWORD=root
```
