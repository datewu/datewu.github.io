---
title: "收集容器syslog"
description: 挂载/dev/log即可
date: 2018-09-03T20:46:00+08:00
tags: [
    "k8s",
    "syslog",
]
categories: [
    "运维",
]
cover:
  image: local-domain-socket.png
draft: false
---

有一个app 跑在pod里面，这个app 默认会输出自己的运行日志到syslogd，

请问如何让host主机上运行的syslogd日志收集器收集到上面app输出的运行日志呢？

## /dev/log
答案：把 主机的 `/dev/log`目录挂载到 pod 里面的 `/dev/log`即可。

> Some of these messages need to be brought to a system administrator’s attention immediately. And it may not be just any system administrator – there may be a particular system administrator who deals with a particular kind of message. Other messages just need to be recorded for future reference if there is a problem. Still others may need to have information extracted from them by an automated process that generates monthly reports.


> To deal with these messages, most Unix systems have a facility called "Syslog." It is generally based on a daemon called “Syslogd” Syslogd listens for messages on a Unix domain socket named /dev/log.

参考[syslog overview](https://www.gnu.org/software/libc/manual/html_node/Overview-of-Syslog.html)

### mountPath

具体来说就在 pod 的yaml 定义中，添加 hostPath volume，然后挂载到pod里：
```yaml
        - name: syslog
          mountPath: /dev/log

      volumes:
        - name: syslog
          hostPath: 
            path: /dev/log

```

在`client-go`等sdk中这样写即可：
```go
          apiv1.Volume{
                      Name: "syslog",
                      VolumeSource: apiv1.VolumeSource{
                          HostPath: &apiv1.HostPathVolumeSource{
                              Path: "/dev/log",
                          },
                      },
                  },
      },
Containers: []apiv1.Container{
    apiv1.Container{
        apiv1.VolumeMount{
            Name:      "syslog",
            MountPath: "/dev/log",
        },
        },
    },

```
