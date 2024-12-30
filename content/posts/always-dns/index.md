---
title: "It's ALWAYS DNS!"
description: upstream dns resolve
date: 2022-05-19T09:30:03+08:00
lastmod: 2022-05-19T09:30:03+08:00
tags: [
    "k8s",
    "nginx",
    "dockerfile",
]
categories: [
    "运维",
]
cover:
  image: dns.jpeg
draft: false
---

今天前端遇到一个问题，前端部署的[反向代理]](/posts/nginx-proxy/)到后端的`upstream`一直pending。 

## timeout？

以为是后端服务压力大，来不及响应，所以更新upstream配置，加上timeout。 立竿见影，没问题了。
```nginx
location /api/ {
    proxy_set_header        Host            $http_host;
    proxy_set_header        X-Real-IP       $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        Upgrade         $http_upgrade;
    proxy_set_header        Connection      'upgrade';
    rewrite                 ^/api/(.*)$ /$1 break;
    proxy_pass              http://api_server/;
    proxy_connect_timeout 5s;
    proxy_send_timeout   10s;
    proxy_read_timeout   10s;
}

```

一段时间后，后端又接受不到前端请求了，nginx一直报错`499`。

## DNS !

调查了一段时间后发现根本问题是nginx的`dns cache`机制的问题。

原来后端每次更新`k8s`后端`deployment`的时候，也会重建`service`从而导致 service的 IP发生了变化。

和后端沟通修改了后端更新流水线脚本，不再重建service 后，问题解决 :)

![check dns](dns.webp)

## dubug

### force resolve (bad performance)
[force nginx to resolve DNS (of a dynamic hostname) everytime when doing proxy_pass?](https://serverfault.com/questions/240476/how-to-force-nginx-to-resolve-dns-of-a-dynamic-hostname-everytime-when-doing-p)

```nginx
server {
    #...
    resolver 127.0.0.1;
    set $backend "http://dynamic.example.com:80";
    proxy_pass $backend;
    #...
}
```

[resolver](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#resolver)
```nginx
resolver 10.0.0.1;

upstream dynamic {
    zone upstream_dynamic 64k;

    server backend1.example.com      weight=5;
    server backend2.example.com:8080 fail_timeout=5s slow_start=30s;
    server 192.0.2.1                 max_fails=3;
    server backend3.example.com      resolve;
    server backend4.example.com      service=http resolve;

    server backup1.example.com:8080  backup;
    server backup2.example.com:8080  backup;
}

server {
    location / {
        proxy_pass http://dynamic;
        health_check;
    }
}

```

### use enviroment (not working)

[/etc/nginx/templates/*.template](https://github.com/docker-library/docs/tree/master/nginx#using-environment-variables-in-nginx-configuration-new-in-119)
```dockerfile
# build stage
FROM node:lts-alpine as build-front
ARG front
WORKDIR /app
COPY package*.json ./
RUN npm config set registry https://mirrors.my-dear-company.com/npm-ok/
RUN npm install
COPY . ./
RUN npm run build

FROM nginx:stable
COPY nginx.template.conf /etc/nginx/templates/api.conf.template
COPY --from=build-front /app/build /usr/share/nginx/html
EXPOSE 80

```
