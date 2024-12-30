---
title: 缓存静态文件
description: 在内存文件系统里缓存nginx caceh
date: 2017-04-29T15:36:18+08:00
tags: [
    "nginx",
    "tmpfs",
]
categories: [
    "运维",
]
cover:
  image: tmpfs.png
draft: false
---

众所周知nginx有很强的分发静态文件的能力，很多时候nginx对静态资源分发能力的瓶颈和`redis`一样在主机的网卡上。

 (一般虚拟机的网卡只有500mbps，如果你使用的是万兆的物理网卡就当我没说）


和redis对比，nginx有另外一个瓶颈在服务器的硬盘IO上，SSD硬盘情况会好一些，
所以很多情况下，我们会把 nginx的cache 做在系统的ssd硬盘上，

其实还可以直接把cache放到内存文件系统里，进一步提升磁盘io吞吐。

## tmpfs

[differences between ramfs and tmpfs](https://www.jamescoyle.net/knowledge/951-the-difference-between-a-tmpfs-and-ramfs-ram-disk)
```shell
#!/bin/bash
mkdir /mnt/ramdisk
mount -t tmpfs -o size=512m tmpfs /mnt/ramdisk

echo 'tmpfs       /mnt/ramdisk tmpfs   nodev,nosuid,noexec,nodiratime,size=1024M   0 0' >> /etc/fstab

```
## nginx

### http cache config
```nginx
http {
    more_set_headers 'Server: CachedLOL';

    proxy_cache_path /var/cache/nginx levels=1:2 use_temp_path=on keys_zone=one:500m max_size=5g inactive=120m;
    proxy_temp_path /var/cache/nginx/tmp 1 2;
}
```

### location conf

```nginx
upstream upV1 {
  server 172.26.2.5:9090 fail_timeout=0;
  server 172.26.2.6:9090 fail_timeout=0;
}

server {
  listen 80 default backlog=16384;
  server_name tab.deoops.com;

  location ~* ( /static.*|/list.+|/ )$ {
    proxy_redirect off;
    proxy_cache one;
    proxy_ignore_headers "Set-Cookie";
    proxy_hide_header "Set-Cookie";
    add_header X-Cache $upstream_cache_status;
    proxy_cache_key $uri$is_args$args$mobile;
    proxy_cache_min_uses 1;
    proxy_cache_valid 120m;
    proxy_cache_use_stale error timeout;
    proxy_buffering on;
    proxy_pass http://upV1;
  }
```

