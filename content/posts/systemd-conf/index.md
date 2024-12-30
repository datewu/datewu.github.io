---
title: "Systemd配置问题"
description: "how systemd eliminated default value: Directive1="
date: 2019-05-11T16:02:39+08:00
tags: [
    "systemd",
    "kubelet config",
    "linux",
    "daemon",
]
categories: [
    "运维",
]
cover:
  image: Systemd_components.svg
draft: false
---

## 问题
用 kubeadm 部署 kubernetes 集群，启动kubelet服务后，kubelet daemon 会认为 `/etc/sysconfig/kubelet`内容的优先级更高， 

覆盖`KUBELET_EXTRA_ARGS`环境变量`--pod-infra-container-image`的配置内容。

### 分析

#### kubelet.service文件
首先查看`/etc/systemd/system/kubelet.service`文件:
```ini
# cat /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

```
注意第5行的ExecStart指令为`/usr/bin/kubelet`

#### kubelet.service.d 目录
然后查看kubelet服务的配置目录`/etc/systemd/system/kubelet.service.d/`，注意
`kubeadm`会在这里创建一个10-kubeadm.conf文件来配置`kubelet`启动方式（参数）。

```ini
# cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet

ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```
配置文件的load的顺序是以字母顺序排列的， 如果我们也在这里创建了kubelet的配置文件，比如20-my-kubelet.conf，`10-*`会先被读取，`20-*`其次。

注意`10-kubeadm.conf`文件的倒数第二行`ExecStart=空行`，这一行等效于`kubeadm`覆盖了上面[kubelet.service](#kubeletservice文件)  的ExecStart指令！


### 结论
`[Service]`覆盖和充值特性。

ExecStart参数特性：如果已经设置`ExecStart`指令参数， 后续ExecStart指令会叠加所有的参数，顺序apply所有指令。

如果想要清空前面的`ExecStart`指令，则需要写一行空的`ExecStart=`,然后写新的ExecStart=......指令。

同理`KUBELET_EXTRA_ARGS`也会有覆盖和清空的语法。

目前我们`/etc/systemd/system/kubelet.service.d/20-my-kubelet.conf`文件是这样的：

```ini
[Service]
Environment="KUBELET_EXTRA_ARGS=--pod-infra-container-image=172.20.8.4/library/pause:3.1 --feature-gates=LocalStorageCapacityIsolation=true \
--kube-reserved-cgroup=/kubepods.slice --kube-reserved=cpu=500m,memory=500Mi,ephemeral-storage=1Gi \
--system-reserved-cgroup=/system.slice --system-reserved=cpu=500m,memory=500Mi,ephemeral-storage=1Gi \
--eviction-hard=memory.available<500Mi,nodefs.available<10%"
```

表面上看 `20-my-kubelet.conf`追加了`KUBELET_EXTRA_ARGS`环境变量，应该是成功的配置了`--pod-infra-container-image`参数，

但是在`10-kubeadm.conf`文件里已经定义`EnvironmentFile=-/etc/sysconfig/kubelet`，然后
在`/etc/sysconfig/kubelet`里有一句`KUBELET_EXTRA_ARGS=`，等于号后面无值，清空了`KUBELET_EXTRA_ARGS`环境变量。

## 解决方案

删除20-my-kubelet.conf文件，直接在/etc/systemconf/kubelet中定义KUBELET_EXTRA_ARGS参数定义：
```ini
# cat /etc/systemconf/kubelet

#KUBELET_EXTRA_ARGS=
KUBELET_EXTRA_ARGS=--pod-infra-container-image=192.168.9.20/library/pause:3.1 --feature-gates=LocalStorageCapacityIsolation=true \
--kube-reserved-cgroup=/kubepods.slice --kube-reserved=cpu=500m,memory=500Mi,ephemeral-storage=1Gi \
--system-reserved-cgroup=/system.slice --system-reserved=cpu=500m,memory=500Mi,ephemeral-storage=1Gi \
--eviction-hard=memory.available<500Mi,nodefs.available<10%
```
修改完配置文件后，执行`kubeadm init`可以看到 `pod-infra-contrainer-image`配置生效了。

参考[systemd config](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
