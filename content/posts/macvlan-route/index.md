---
title: "Macvlan路由规则"
description: bypass内核路由规则
date: 2019-03-11T11:33:48+08:00
tags: [
    "macvlan",
    "route",
    "network",
    "python",
]
categories: [
    "运维",
]
cover:
  image: Macvlan-network-with-traffic-flows.png
draft: false
---


对macvlan 不熟悉的同学，可以先看下这篇[macvlan virtual network简介](https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking/#macvlan)

默认情况下Linux kernel会阻止(drop)宿主机（host eth0）虚拟出来的 macvlan network（`bridge mode`） 和宿主机host eth0）之间网络数据包。

调试了一段时间后，我们发现了可以通过路由表来绕过这个限制。
具体实施的方法如下：

> 在host network namesapces下新增 一个macvlan device，然后添加路由规则即可。

通信的两个方向简单解释如下：
## eth0(host) -> pod(macvlan)

宿主机host eth0 通过break0 设备 和route table的路由规则 可以访问到pod（在macvlan中）
 
shell调试脚本如下：
```shell
ip link add break0 link eth0 type macvlan mode bridge
# NOTE: if use /24 CIDR will auto add a route rule 
# (100.75.30.0/24 dev break0 proto kernel scope link src 100.75.30.1) 
# which we don't need
ifconfig break0 100.75.30.7/32 up 
ip r a 100.75.30.71 dev break0 # 100.75.30.71 is a pod ip for test
```

因为kuryr是用python配置网络的，所以也提供对应的python脚本如下：
```python
from pyroute2 import IPDB

def _create_break0(self):
    with IPDB() as ipdb:
        i = ipdb.interfaces.get(IF_NAME)
        if i:
            i.up().commit()
            return i.index
        try:
            with ipdb.create(
                ifname=IF_NAME,
                kind=MACVLAN_KIND,
                link=ipdb.interfaces[self.parent],
                macvlan_mode=MACVLAN_MODE_BRIDGE,
            ) as i:
                i.add_ip(self.addr + "/32")
                i.up()
            return i.index
        except ipdb_exceptions.CreateException as e:
            LOG.info("Exception when create break0 device %s", e)
            return 0

def _route_spec(self, ip):
   return {"dst": ip + "/32", "oif": self.idx}

def add_route(self, ip):
    spec = self._route_spec(ip)
    with IPDB() as ipdb:
        try:
            ipdb.routes.add(spec).commit()
        except (ipdb_exceptions.CommitException, link_exceptions.NetlinkError) as e:
            LOG.info("Exception %s when add route table " + ip, e)
```


## pod -> eth0(host)

因为是2层打通的，所以只要有mac_addr就可以访问，和pod以及宿主机eth0**具体的IP** 地址没关系。

在pod 里面使用 `arp -n` 可以看到，host IP（100.75.30.51） 和 break0 （100.75.30.7）  的IP
对应的是同一个mac addr， 都是 break0的mac addr。


在主机上添加 路由 `ip r add 100.75.30.71 dev break0` （100.75.30.71 是pod 的IP地址），

然后在 pod 上ping 下 host IP， 宿主机eth0的hostIP 和 break0 的两个条目就会在pod的arp 表里显示出来。

如果只是从 host ping pod， 则 pod的arp 表只显示 break0 这个条目。
