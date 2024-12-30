---
title: 两个奴隶
description: 给高可用的postgresql集群，再加一个只读的slave。
date: 2018-02-05T21:55:41+08:00
tags: [
    "postgresql",
    "high available",
    "streaming replication",
    "react",
]
categories: [
    "运维",
]
cover:
  image: postgres-replication.jpeg
draft: false
---

一般postgres高可用集群是一个master配一个slave，但是开发这边需要做db的读写分离，所以运维这边
又添加了一台slave专门暴露出来做读操作。原来的slave还是只做备份。

## HA
一主一从高可用的配置可以参考下面这篇文章
[postgres streaming replication](https://altecnotes.wordpress.com/2017/03/24/streaming-replication-with-postgresql/)，有时间的话我可能会搬运一下 :)

## 安装配置
因为pg数据库集群已经配置好了一主一从，所以在master主机上**不需要**配置`pg_hba.conf`,
或者`CREATE ROLE`等等。

添加第二个`slave`需要注意以下两点：

1. 等待pg_basebackup`replicas stream`数据同步完成后，再启动 `postgresql-9.6 service`;
2. 修改`PG_DATA_DIR`目录的权限;
```shell
rm /etc/yum.repos.d/pgdg-96-redhat.repo 
yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum install -y postgresql96
yum install -y postgresql96-server
yum install -y postgresql96-contrib
vi /usr/lib/systemd/system/postgresql-9.6.service
mkdir /data/pg9.6
chown postgres:postgres /data/pg9.6/
ls -alh /data/pg9.6/
pg_basebackup --help

## you can add option --checkpoint=fast for an instance backup
## qhich is not recommend
pg_basebackup -X stream -D /data/pg9.6/ -P -R -h 10.3.3.3 -U replicator
ls /data/pg9.6/
cat /data/pg9.6/recovery.conf
vi /data/pg9.6/postgresql.conf
pwd
systemctl start postgresql-9.6.service 
ls -alh /data/pg9.6/
chown -R postgres:postgres /data/pg9.6
chmod 700 /data/pg9.6
systemctl start postgresql-9.6.service 
netstat -nlp | grep 5432
su - postgres
systemctl enable postgresql-9.6.service 
```

### check
在master主机上查看`pg_stat_replication`表数据，验证第二个slave是否正常工作：
```shell
# on MASTER machine
[dba_lol@pg_master ~]$ sudo su - postgres
上一次登录：五 2月 23 17:12:02 HKT 2018pts/1 上
-bash-4.2$ psql
psql (9.6.6)
Type "help" for help.

postgres=# select * from pg_stat_replication;
 pid  | usesysid | usename | application_name | client_addr | client_hostname | client_port |         backend_start         | backend_xmin |   state   | sent_location | write_location | flush_location | replay_location | sync_priorit
y | sync_state 
------+----------+---------+------------------+-------------+-----------------+-------------+-------------------------------+--------------+-----------+---------------+----------------+----------------+-----------------+-------------
--+------------
 6720 |    19367 | replicator | walreceiver      | 10.2.2.2    |                 |       49308 | 2018-01-24 18:20:47.114058+08 |              | streaming | 82/6B07DD60   | 82/6B07DD60    | 82/6B07DD60    | 82/6B07DD20     |             
0 | async
  446 |    19367 | replicator | walreceiver      | 10.2.2.4   |                 |       54836 | 2018-02-21 13:21:39.420745+08 |              | streaming | 82/6B07DD60   | 82/6B07DD60    | 82/6B07DD60    | 82/6B07DD20     |             
0 | async
(2 rows)

postgres=# 
```

## PS
### add slave to slave
编辑`recover.conf`  文件 的 `primary_conninfo`地址信息可以实现`slave` ->  `slave`的数据同步。
