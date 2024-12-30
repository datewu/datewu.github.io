---
title: 证书问题
description: 容器内进程HTTP GET报错 
date: 2019-09-12T10:11:32+08:00
tags: [
    "docker",
    "certificate",
    "https",
    "x509",
]
categories: [
    "运维",
    "生活",
]
cover:
  image: common-ca.png
draft: false
---

`docker run`调试某个container报如下所示`x509`证书错误，一开始怀疑是容器网络（`--network host`) 的问题 :

```shell
[deoops@dev-3 ~]# docker run  --network host  datewu/controller:v0.0.2
{"level":"panic","error":"Get https://google.com: x509: certificate signed by unknown authority","time":1555498448,"message":"get max item failed"}
panic: get max item failed

goroutine 26 [running]:
github.com/rs/zerolog.(*Logger).Panic.func1(0x7773e9, 0x13)
        /Users/deoops/go/pkg/mod/github.com/rs/zerolog@v1.13.0/log.go:307 +0x4f
github.com/rs/zerolog.(*Event).msg(0xc00012e8a0, 0x7773e9, 0x13)
        /Users/deoops/go/pkg/mod/github.com/rs/zerolog@v1.13.0/event.go:141 +0x1c1
github.com/rs/zerolog.(*Event).Msg(...)
        /Users/deoops/go/pkg/mod/github.com/rs/zerolog@v1.13.0/event.go:105
main.catchUp()
        /Users/deoops/github/controller/work.go:69 +0x326
main.populate(0xc000114000)
        /Users/deoops/github/controller/worker.go:10 +0x26
created by main.initWork
        /Users/deoops/github/controller/work.go:84 +0x7f
```

错误信息大概是说 client 不能识别google的https 证书， 可能是base image `alpine`的问题。

将`base image`改为 `scratch` ，结果还是会报`x509`错。

## 解决方案
给 `alpine`镜像 [加上ca-certificates](https://support.circleci.com/hc/en-us/articles/360016505753-Resolve-Certificate-Signed-By-Unknown-Authority-error-in-Alpine-images)解决了问题:

```dockerfile
FROM alpine
# add Common CA certificates PEM files
RUN apk --no-cache add ca-certificates

# ....
# docker build -t datewu/alpine-ca .
```
以后用到`alpine`的Dockerfile 直接 `FROM datewu/alpine-ca` 问题解决啦😄

> 总结一下：当容器里的进程访问外部tls server时，如果容器内没有配置Common CA certificates，客户端就会出现无法识别server证书的问题。

ps:
今天在写字楼二楼快餐店吃晚饭的时候，遇到两个建筑工人，50-60岁的样子，像是夫妻。

两个人一起打才吃了10块钱：一人一个素菜，豆芽菜和黑油白。

pps：快餐店下午的汤是免费的，所以他们一人又拿了一碗汤，

回想起今天我过早才就吃了10块钱，嗟乎唏嘘。
