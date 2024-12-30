---
title: 部署moodle
description: 在centos上部署moodle和postgresql
date: 2018-03-20T13:58:27+08:00
tags: [
    "LAMP",
    "postgresql",
    "nginx",
    "php",
    "php-fpm",
    "moodle",
]
categories: [
    "运维",
]
cover:
  image: moodle.png
draft: false
---

客户需要部署一套 [moodle](https://download.moodle.org/releases/latest/) 教学系统。

去[moodle官网](https://moodle.org/)大致看了一圈，发现moodle 是一个典型的PHP web应用。

其实这种`LAMP (Linux, Apache, MySQL, PHP/Perl/Python)`的应用，

我一般会用docker componse快速部署的，比如这个[docker componse](https://github.com/bitnami/bitnami-docker-moodle/blob/master/docker-compose.yml)看上去就很不错。

但是客户不想用docker，要求直接在vm上部署。

初步确认部署环境为： `nginx(let's encrypt)` + `php 7.2` +  `pg 10` + `Centos 7.4` 。

## 安装软件
### 初始化主机
```shell
hostnamectl set-hostname deoops.com
# disable passwd login; use ssh-key only
vi /etc/ssh/sshd_config  
yum update -y
yum upgrade -y
init 6

# add remi repo
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
```

### 安装nginx

```shell
yum install nginx
yum -y install yum-utils
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
## 安装let's encrypt certbot
yum install certbot-nginx
systemctl enable nginx
systemctl start nginx

## 签发证书
certbot --nginx certonly
ls -alh /etc/nginx/
```

### 安装php dependency
```shell
yum --enablerepo=remi,remi-php72 install php-fpm php-common php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongodb php-pecl-redis php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml

```

### 配置nginx + php-fpm
详细的配置内容看[这里](#配置)
```shell
vi /etc/nginx/nginx.conf
ls
mv mood.conf /etc/nginx/conf.d/
ls -ahl /etc/php-fpm.d/
mv www.conf /etc/php-fpm.d/
mv php.ini /etc/
systemctl start php-fpm.service
systemctl enable php-fpm.service
```

### 安装postgresql 10
```shell
fdisk -l
bash newDisk.sh /dev/vdb
mkdir /media/data/mood
mkdir /media/data/pgdata
yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm -y
yum install postgresql10 -y
yum install postgresql10-server postgresql10-contrib  -y
ls -alh /var/lib/pgsql/10/data/
chown -R postgres:postgres /media/data/pgdata
vi /usr/lib/systemd/system/postgresql-10.service 
/usr/pgsql-10/bin/postgresql-10-setup initdb
systemctl enable postgresql-10
systemctl start postgresql-10
```
#### 配置postgresql hba
```shell
netstat -nlp
vi /media/data/pgdata/pg_hba.conf 
systemctl restart postgresql-10
netstat -nlp
```


### 安装moodle 34
```shell
ls
mv moodle-latest-34.tgz zh_cn.zip /media/data/mood/
cd /media/data/mood/
ls
tar xzf moodle-latest-34.tgz 

vi /etc/nginx/conf.d/mood.conf 
chown -R nginx:nginx /media/data/mood
ls -alh /var/lib/php/session/
ls -alh /run/php-fpm/
netstat -nlp | grep php
chown -R nginx:nginx /var/lib/php/session/
systemctl restart php-fpm
su - postgres 
```

### 安装moodle依赖包
安装 `zip`,`xmlrpc`,`soap`等依赖包：
```shell
yum --enablerepo=remi,remi-php72 install php72-php-zip
systemctl restart php-fpm.service 
systemctl restart nginx.service 
init 6


yum --enablerepo=remi,remi-php72 install  php72-php-pecl-zip
yum --enablerepo=remi,remi-php72 install php-zip
systemctl restart php-fpm.service 
systemctl restart nginx
yum --enablerepo=remi,remi-php72 install php-intl
yum --enablerepo=remi,remi-php72 install phpxmlrpc
yum --enablerepo=remi,remi-php72 install php-xmlrpc
yum --enablerepo=remi,remi-php72 install php-soap
systemctl restart nginx
systemctl restart php-fpm.service 

```

## 配置

### 配置nginx php-fpm
moodle使用的nginx 配置，基本适用于所有的php 应用：
```nginx
# PHP Upstream Handler
upstream php-handler {
    server unix:/run/php-fpm/php-fpm.sock;
}

server {
    server_name  moodle-demo.deoops.com;

    ssl  on;
    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/moodle-demo.deoops.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/moodle-demo.deoops.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

        root         /media/data/mood/moodle;
        rewrite ^/(.*\.php)(/)(.*)$ /$1?file=/$3 last;

        location ^~ / {
                try_files $uri $uri/ /index.php?q=$request_uri;
                index index.php index.html index.htm;

                location ~ \.php$ {
                        include fastcgi.conf;
                        fastcgi_pass php-handler;
                }
        }

}

# http -> https
server {
    if ($host = moodle-demo.deoops.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen       80 ;
        listen       [::]:80 ;
        server_name  moodle-demo.deoops.com;
    return 404; # managed by Certbot

}
```
### 配置https证书
配置let's encrypt自更新`crontab` job:
```shell
certbot renew --dry-run
crontab -e
crontab -l
0 0,12 * * * python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew 
```

## 参考
[moodle: set up postgresql counts and database](https://docs.moodle.org/33/en/PostgreSQL)

[PHP(php-fpm) nginx](https://www.howtoforge.com/tutorial/how-to-install-moodle-32-on-centos-7/)
