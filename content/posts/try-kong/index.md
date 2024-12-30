---
title: kong网关
description: 评估kong API网关
date: 2018-02-03T18:05:04+08:00
lastmod: 2018-02-04T16:37:26+08:00
tags: [
    "gateway",
    "nginx",
]
categories: [
    "运维",
]
cover:
  image: kong.png
draft: false
---

updated: kong不满足要求，后面调研了另外一个API产品 [orange](/posts/try-orange)

2015年接触openresty的时候接触过kong，了解到kong是基于openresty二次开发的商业产品，

正好目前新公司要调研稳定好用的`API Gateway`产品，所以本文简单记录下我对kong的安装配置感受。

## 安装
```shell
yum install https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=centos/7/kong-community-edition-0.12.1.el7.noarch.rpm
kong
systemctl stop nginx
netstat -nlp
netstat -nlp|grep 80
ls
date
vi /etc/kong/kong.conf.default
vipw
su - postgres
create user kong;
create database kong ownner kong;
create database kong owner kong;

cd /etc/kong/
cp kong.conf.default kong.conf
vi kong.conf
kong migrations up
psql -U kong
tail /media/data/pgdata/log/postgresql-Wed.log
vi /media/data/pgdata/pg_hba.conf
systemctl restart postgresql-10.service
kong migrations up
kong
kong check
kong start
netstat -nlp | grep 80
which nginx
curl localhost:
netstat -nlp
vi /usr/local/kong/nginx-kong.conf
which -a nginx
kong
kong restart --nginx-conf /etc/nginx/nginx.conf
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.tmpl
vi /etc/nginx/nginx.conf.tmpl
kong restart --nginx-conf /etc/nginx/nginx.conf.tmpl

which -a npm

```
### 安装控制台
使用
```shell
which -a docker
yum remove docker                   docker-common                   docker-selinux                   docker-engine
yum install -y yum-utils   device-mapper-persistent-data   lvm2
yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce
systemctl start docker
docker run hello-world
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://2b77623e.m.daocloud.io
systemctl restart docker
systemctl enable docker
docker run -d --rm -p 8080:8080 pgbi/kong-dashboard start   --kong-url http://10.0.0.1:8001 --basic-auth usrtest=pwdtest
docker ps -a

 ### registe the very first api through kong admin api
curl -i -X POST --url http://10.0.0.11:8001/apis  --data 'name=admin-api' --data 'hosts=a.k.deoops.com' --data 'upstream_url=http://localhost:8080'

```

## 小结
开源Kong 的限制比较多，[反向代理](/posts/nginx-proxy/)配置基本上靠插件，对现存的nginx的conf兼容性不友好。
简单的`proxy_cache`配置一定要企业版才支持，下面的更加`精细`配置也没有支持： 
```nginx
 valid_referers *.deoops.cn deoops.cn  *.deoops.com deoops.com;
 add_header 'Access-Control-Allow-Headers' 'os, ver, hwid, innerver, channel, net, token, et';
 proxy_cache my_cache;
 proxy_cache_valid 200 302 304 10s;
 proxy_ignore_headers Expires Cache-Control Set-Cookie;
 proxy_cache_key $host$request_uri$is_args$args$http_token;
 
 if ($request_uri ~ img_vercode ){
 set $no_proxy_cache 1;
 }
 if ($remote_addr = 114.13.118.24){
 set $no_proxy_cache 1;
 }

```
