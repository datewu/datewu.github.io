---
title: orange网关
description: 评估orange API网关
date: 2018-02-05T19:37:23+08:00
tags: [
    "nginx",
    "api",
    "gateway",
]
categories: [
    "运维",
]
cover:
  image: orange.png
draft: false
---

几天之前试用过了[kong](/posts/try-kong)效果不理想 ，今天来使用下小米出品（存疑？）的 [orange](https://github.com/sumory/orange)网关。

一个明显的区别是 kong的后端存储使用了postgresql，orange使用的是mysql。

好了，废话不多说，贴出安装部署的过程如下：

## 安装
### mysql
```shell
#!/bin/bash
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum update
sudo yum install mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
vi save_your_root_pwd
git clone https://github.com/sumory/orange.git
cd orange/
ls
cd install/
ls
head orange-v0.6.4.sql
head -n 100 orange-v0.6.4.sql
head -n 50 orange-v0.6.4.sql
mysql -V
mysql -u root -p
cd orange/
cd install/
ls
mysql -u o_usr -p  o_database < orange-v0.6.4.sql
mysql -u o_usr -p  o_database

```

### orange
```shell
#!/bin/bash
yum remove kong-community-edition ## get rid of annoying lua 5.1  version conflict
cd /data/nginx/conf/
cp api.conf api.conf.bak.18.03.09 ## always backup conf files : )
nginx -s stop
netstat -nlp | grep 443
 mv /usr/sbin/nginx /usr/sbin/nginx_old
 yum install yum-utils
yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
 yum install openresty  openresty-resty -y
git clone https://github.com/sumory/orange.git
git clone https://github.com/sumory/lor.git
pwd
mv lor ~
mv orange ~
cd
ls
cd lor/
make install
cd ../orange/
make install
cd
ln -s /usr/local/bin/orange /bin/orange
ln -s /usr/local/openresty/nginx/sbin/nginx /bin/nginx
mv /home/deoops/orange.conf /home/deoops/nginx.conf /usr/local/orange/conf/
vi /usr/local/orange/conf/orange.conf ## make sure orange.conf has the right mysql server info
vi /data/nginx/conf/api.conf
chown root:root /usr/local/orange/conf/*.conf
orange start
netstat -nlp | grep 443

```

## 小结
用了几天，感觉UI比起kong来说简单些，开箱即用的功能比kong也多一些。
稳定性还有待进一步的观察。
