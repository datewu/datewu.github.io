---
title: "pod生命周期事件生成器"
description: 由kuryr cni引发的pleg not healthy问题
date: 2019-02-11T10:33:42+08:00
tags: [
    "k8s",
    "docker",
]
categories: [
    "运维",
]
cover:
  image: reboot.jpeg
draft: false
---

## PLEG
不熟悉PLEG(Pod Lifecycle Event Generator)的同学，可以先看下这篇文章[What is PLEG?](https://developers.redhat.com/blog/2019/11/13/pod-lifecycle-event-generator-understanding-the-pleg-is-not-healthy-issue-in-kubernetes)。

这篇文章对pleg是什么和常见的`unhealthy`问题有很详细的介绍。

### cni
当k8s的 cni 插件性能较差，node上的pod 数量较多（大于 80）的时候，我们常常会遇到PLEG出错的问题:

> PLEG is not healthy: pleg was last seen active 6m55.488150776s ago; threshold is 3m0s

调试[kuryr](https://github.com/openstack/kuryr-kubernetes) cni的时候，发现当openstack `neutron`服务压力比较大的时候。

cni这边申请和释放 port的时延会相应的增加，导致虚拟机大量堆积无效的netns，

然后就会遇到由`kueblet PLEG not healthy`引起的docker hang 住问题。

## docker
重启 docker  和 kueblet 可以暂时解决PLEG unhealthy。

```shell
systemctl restart docker
systemctl restart kubelet
# do NOT use `docker rm -vf`,
# which will kill running containers
docker rm -v `docker ps -qa`
```

建议同时修改 [kubelet 启动参数](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/troubleshoot/docker_pods_overload.html) --housekeeping-interval=30s

