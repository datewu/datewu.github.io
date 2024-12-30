---
title: "容器PID"
description: 如何区分宿主机上的进程和容器上的进程
date: 2020-03-13T22:43:32+08:00
tags: [
    "cgroup",
    "linux",
    "proc",
    "matrix",
]
categories: [
    "运维",
]
cover:
  image: the-matrix.jpeg
draft: false
---
架构部的同事问了我两个问题:

1. 宿主机上有个进程很耗 cpu，怎么判断它是不是某个容器的进程;
2. 如果它是跑在容器里，怎么查到是哪个容器(container id);

## 解决方案
有两种方法来解决上面两个问题：
### cgroup
通过查看pid的cgroup是否含有 `slice`信息来判断是否是容器进程:

#### 主机进程 cgroup
直接运行在宿主机主的进程的cgroup是没有`slice`信息的：
```bash
[root@deoops ~]# cat /proc/1/cgroup
11:perf_event:/
10:memory:/
9:devices:/
8:cpuacct,cpu:/
7:cpuset:/
6:hugetlb:/
5:blkio:/
4:net_prio,net_cls:/
3:freezer:/
2:pids:/
1:name=systemd:/
[root@deoops ~]# cat /proc/19/cgroup
11:perf_event:/
10:memory:/
9:devices:/
8:cpuacct,cpu:/
7:cpuset:/
6:hugetlb:/
5:blkio:/
4:net_prio,net_cls:/
3:freezer:/
2:pids:/
1:name=systemd:/
```
#### k8s pod进程 cgroup
在宿主机上看跑在容器进程的cgroup是可以看到`slice`信息的：
```bash
[root@deoops ~]# cat /proc/20397/cgroup
11:perf_event:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
10:memory:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
9:devices:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
8:cpuacct,cpu:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
7:cpuset:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
6:hugetlb:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
5:blkio:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
4:net_prio,net_cls:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
3:freezer:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
2:pids:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope
1:name=systemd:/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod6d62265d_cd4d_4807_8d2f_386714d5bbdc.slice/docker-c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc.scope

```
 从上面的输出可以看到 pid `20397`是 kubernets pod拉起来的进程， 而且`pod ID` 是：
 `6d62265d_cd4d_4807_8d2f_386714d5bbdc`, 对应的 `contariner ID` 是
  `c44a782ba5482052e66dc3f5ed3811e2a699db09b6715e26102d582a51ac52cc`

#### docker container进程 cgroup
docker containre 和 k8s 一样，也会设置cgroup slice：
```bash
[root@deoops ~]# docker run --name mysql  -p 3306:3306  -e MYSQL_ROOT_PASSWORD=super123456secret -d mysql:5.7.28
Unable to find image 'mysql:5.7.28' locally
5.7.28: Pulling from library/mysql
804555ee0376: Pull complete
c53bab458734: Pull complete
ca9d72777f90: Pull complete
2d7aad6cb96e: Pull complete
8d6ca35c7908: Pull complete
6ddae009e760: Pull complete
327ae67bbe7b: Pull complete
31f1f8385b27: Pull complete
a5a3ad97e819: Pull complete
48bede7828ac: Pull complete
380afa2e6973: Pull complete
Digest: sha256:b38555e593300df225daea22aeb104eed79fc80d2f064fde1e16e1804d00d0fc
Status: Downloaded newer image for mysql:5.7.28
771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633


[root@deoops ~]# ps aux | grep mysql
polkitd  23855  3.0  1.1 1007636 190588 ?      Ssl  09:39   0:00 mysqld
root     24176  0.0  0.0 112724   984 pts/0    S+   09:39   0:00 grep --color=auto mysql


[root@deoops ~]# cat /proc/23855/cgroup
11:perf_event:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
10:memory:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
9:devices:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
8:cpuacct,cpu:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
7:cpuset:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
6:hugetlb:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
5:blkio:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
4:net_prio,net_cls:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
3:freezer:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
2:pids:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
1:name=systemd:/system.slice/docker-771aa2fdc8cae66a0cb05a4585beff44a69f0f1c5b2a21fd159cbeea0a86d633.scope
[root@deoops ~]# docker ps | grep 771aa2fdc
771aa2fdc8ca        mysql:5.7.28                                                        "docker-entrypoint.s…"    58 seconds ago      Up 57 seconds       0.0.0.0:3306->3306/tcp, 33060/tcp   mysql

```

从上面bash脚本的输出可以清楚的看到，cgroup配置的`container ID` 和 docker ps 命令输出的 `container ID`是一样的，都是 `771aa2fdc8ca`

### ppid
下面两种方法和docker强相关，不推荐。
#### pstree
老老实实的一步步排查主机上所有的container ppid：
用 `pstree`命令查看宿主机上的进程树，看`<pid>` 是不是`docker-current`创建的子进程;

#### docker inspect
使用`docker inspect`命令查询所有容器的pid，然后做过滤，找到该进程对应的容器名，id，容器的详细信息中，包含了它在宿主机上的进程号。
```bash
docker inspect -f "{{.Id}} {{.State.Pid}} {{.Config.Hostname}}"  $(docker ps -q) | grep <pid>
```

## 发散思维

### MATRIX
那么进程自己如何判断自己是否在container中呢？

答案很简单，如果 `pid 1` 的cgroup有slice信息，说明进程现在在容器中，否则则说明不在容器里。
```bash
[root@deoops ~]# kubectl exec -it binary-controller-7dfd4bbd6f-6hsvd sh
/ # ps
PID   USER     TIME  COMMAND
    1 root      0:30 /binary-controller -kubeconfig=inCluster -mode=prodution
  196 root      0:00 sh
  202 root      0:00 ps


/ # cat /proc/1/cgroup 
11:hugetlb:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
10:pids:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
9:perf_event:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
8:freezer:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
7:memory:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
6:net_prio,net_cls:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
5:blkio:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
4:cpuacct,cpu:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
3:devices:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
2:cpuset:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope
1:name=systemd:/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod482f0a01_7b3e_48cd_adb6_61c9097b43a4.slice/docker-b3079dba7a1cf909631c2f9e8ad38cc7f193e6ba8fe649d4d6f590a7d11b0509.scope

## OH NO, I'M IN THE MATRIX

```
