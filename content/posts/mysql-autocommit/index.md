---
title: "Mysql Autocommit问题"
description: orm很大程度会反噬开发人员
date: 2019-04-12T10:37:04+08:00
tags: [
    "mysql",
    "orm",
    "golang",
]
categories: [
    "运维",
]
cover:
  image: Start-ad-hoc-Transaction.jpeg
draft: false
---


客户反馈我们的产品有个很奇怪的问题。

添加完商品后，可以看到商品，但是一刷新页面，刚才添加的商品就消失啦。

以前没碰到过，一直都用的好好的为什么今天就不行了呢？

## 分析问题
既然一刷新即消失了，就证明没有写入到数据库。

没写入到数据库是什么原因呢？ API 也没有报错呀？

更加奇怪的是，有的页面有这个问题，有的没有这个问题。

后端的API 有的是golang写的，有的是Java写的。

`golang` orm对mysql 数据库的写操作存在上面说的刷新就丢失的问题，`Java`的orm对mysql的写操作没有问题。


这是为什么呢？

##  DBA
排查了很久发现原来是客户那边的DBA把 mysql的 `session autocommit`的配置关闭啦。

[autocommit](https://dev.mysql.com/doc/refman/5.6/en/innodb-autocommit-commit-rollback.html)

翻了下文档，确定　`Java`的orm框架会忽略mysql server的配置默认自己commit，`golang`的orm则没有这个优化（也许是有但我们没有启用？）。

所以会出现 java的后端是正常的，golang的后端写不了mysql。
 　
## 解决方案
客户DBA开启`autocommit`配置项后，产品业务恢复正常。
