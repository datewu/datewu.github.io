---
title: 试用Azure Centos虚拟机
description: 看看微软大佬的主机托管服务咋样
date: 2017-11-15T10:48:20+08:00
tags: [
    "azure",
    "centos",
]
categories: [
    "运维",
]
cover:
  image: Azure.png
draft: false
---
换了份工作，新公司是做加密币交易所的，服务器都在国外。所以有机会接触到了微软的azure云服务，
服务器基本都在亚太区新加坡。

ps：这是我第一次实操单台配置32c64g的虚拟机，纪念一下。以前工作中最多就8c16g，数量的话两三百台机器。

## history
```shell
uname -a # kernel info
cat /etc/redhat-release 

df -alh  # query disk info
ifconfig 
ping 10.0.0.6
ssh  10.0.0.6
ls .ssh/
mv azagent .ssh/id_rsa
ls -alh .ssh/id_rsa 
ssh  10.0.0.6

ping  jd.com
yum install yum-utils
 sudo yum install yum-utils
yum -y upgrade
sudo yum -y upgrade
sudo yum -y update
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo


sudo yum install openresty # install web server
sudo vi /etc/ssh/sshd_config 
systemctl status sshd
systemctl restart sshd
sudo systemctl restart sshd


yum install ansible
sudo yum install ansible
sudo systemctl status openresty
sudo systemctl enable openresty
sudo systemctl start openresty
curl -I localhost
uptime
date
sudo install git
sudo yum install git
locate openresty
rpm -qc openresty  # query configuration file
wget https://copr.fedorainfracloud.org/coprs/dheche/prometheus/repo/epel-7/dheche-prometheus-epel-7.repo
ls
head dheche-prometheus-epel-7.repo 
suod mv dheche-prometheus-epel-7.repo /etc/yum.repos.d/prometheus.repo
sudo mv dheche-prometheus-epel-7.repo /etc/yum.repos.d/prometheus.repo
sudo yum install prometheus
sudo yum install prometheus-node
sudo vi /etc/yum.repos.d/prometheus.repo 


sudo yum install prometheus
sudo yum install prometheus2
sudo yum install node_exporter
sudo yum install alertmanager


vi /etc/hosts
sudo vi /etc/hosts
ssh ten 

sudo vi /etc/yum.conf 
ls /var/cache/yum/x86_64/7/prometheus/
ls /var/cache/yum/x86_64/7/prometheus/packages/
ls -alh  /var/cache/yum/x86_64/7/prometheus/packages/
ls
sudo yum install yum-utils
history 
sudo yumdownloader  prometheus  
ls
ls -alh 


sudo yumdownloader  prometheus2 # download installed rmp packages
sudo yumdownloader  node_exporter.x86_64 
sudo yumdownloader  alertmanager.x86_64 
ls -alh 


scp node_exporter-0.15.2-1.el7.centos.x86_64.rpm ten:

ssh ten 
ssh ten 'sudo systemctl enable node_exporter'
ssh ten 'sudo systemctl start node_exporter'

sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl enable alertmanger
sudo systemctl enable alertmanager
sudo systemctl start alertmanager
netstat -nlp


sudo -i # su to root
pwd
ls
rm prometheus-1.8.2-1.el7.centos.x86_64.rpm 
ls
sudo systemctl enable prometheus
sudo systemctl start prometheus
cat/etc/passwd


rpm -qc prometheus2
ls -alh /etc/default/prometheus 


id prometheus
cat /etc/default/prometheus 
ls -alh /etc/prometheus/
sudo -i
```

总的说来敲了100来条指令，比较重要的是下面三条指令：
1. `sudo -i`切换为root用户；
2. `yumdownloader `保存通过yum安装的rpm包 (配合`yum -C install `和`SCP`可以加快LAN下所有主机的安装速度)；
3. `rpm -qc `查询安装包配置信息;

## timeout
默认情况下，Azure 的Linux主机的`sshd` 服务会把闲着超过1分钟的客户端踢下线`ssh session timeout`。
修改本地`ssh` 客户端连接配置添加`ServerAliveInterval`等配置项就可以规避上面说的timeout限制：
```shell
#### .ssh/config snippet
HOST singapore2
  HostName 40.50.60.70
  IdentityFile ~/.ssh/az
  ServerAliveInterval 120
  ServerAliveCountMax 30
  ConnectTimeout 30
```
