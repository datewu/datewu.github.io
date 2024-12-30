---
title: 数据库备份
description: 使用psql和pg_dump定时备份两个postgresql数据库
date: 2018-02-24T11:21:55+08:00
tags: [
    "cron",
    "postgresql",
    "backup",
    "psql",
]
categories: [
    "运维",
]
cover:
  image: postgresql-backup.jpeg
draft: false
---

工作需要定时备份postgresql slave数据库数据数据，服务器上运行了两个`slave`实例，隶属于两个不同的`master`。


## 备份
两个`slave server`实例分别监听在 `5432`和 `4432`端口
```shell
#!/bin/bash
#
# Daily PostgreSQL maintenance: vacuuming and backuping.
#
##
set -e
for port in 5432 4432; do
  BACKDIR="/data/pg_back/$port"
  [ -d $BACKDIR ] || mkdir -p $BACKDIR

  echo "[`date`] begin Maintaining pg on port $port"
  
  # no need to use -U option for DB in $(psql -l -t -p $port |awk '{ print $1}' |grep -vE '^-|:|^List|^Name|template[0|1]|postgres|\|'); do
  
  ### swith form 'awk and grep' hacks to psql options and 'select sql'
  ### which is more dbaer professioner :)
  
  for DB in $(psql -AqXtc 'SELECT datname FROM pg_database WHERE datistemplate = false;'); do
    echo "  [`date`] Maintaining $DB"
    PREFIX="$BACKDIR/$DB"
    
    # NO need to do `vacuum` on slaves
    # do `vacunm` on master instead
    # echo 'VACUUM' | psql -U postgres -hlocalhost -d $DB
    DUMP="$PREFIX.`date '+%Y%m%d'`.sql.gz"
    # no need for -U postgres option
    pg_dump -p $port $DB | gzip -c > $DUMP
    PREV="$PREFIX.`date -d'1 day ago' '+%Y%m%d'`.sql.gz"

    # md5sum -b $DUMP > $DUMP.md5
    md5=($(md5sum -b $DUMP))
    echo $md5 > $DUMP.md5
    if [ -f $PREV.md5 ] && diff $PREV.md5 $DUMP.md5; then
      rm -f $PREV $PREV.md5
    fi
    ## delete too old backup
    TOOOLD="$PREFIX.`date -d'15 day ago' '+%Y%m%d'`.sql.gz"
    [ -f $TOOOLD ] ||  rm -f $TOOOLD
  done
  echo "[`date`] Maintain pg on port $port finished"
done
```

[参考：Automatic Offsite PostgreSQL Backups Without a Password](https://luxagraf.net/src/automatic-offsite-postgresql-backups)

[参考：Only get hash value using md5sum (without filename) ](https://stackoverflow.com/a/5773761)

### 定时
```shell
chmod +x pg_backup.sh
su - postgres
crontab -e

# 16 2 * * * /var/lib/pgsql/pg_backup.sh >> /var/log/psql_corn_bak.log

# */3 * * * * /var/lib/pgsql/pg_backup.sh >> /var/log/psql_corn_bak.log 2>&1 ## every 3 minutes

```

## psql
一般情况下`psql`的工作模式是和人的相互交互模式(interpreter)，在shell脚本里可以使用下面的options ` -AqXt -c`
会更实用写
```shell
-A: The output is not aligned; by default, the output is aligned.
-q (quiet): This option forces psql not to write a welcome message or any other
informational output.
-t: This option tells psql to write the tuples only, without any header
information.
-X: This option informs psql to ignore the psql configuration that is stored in
~/.psqlrc file.
-o: This option specifies psql to output the query result to a certain location.
-F: This option determines the field separator between columns. This option can
be used to generate CSV, which is useful to import data to Excel files.
PGOPTIONS: psql can use PGOPTIONS to add command-line options to send to the
server at runtime. This can be used to control statement behavior such as to
allow index scan only or to specify the statement timeout.

```
### demo
```shell
#!/bin/bash
connection_number=`PGOPTIONS='--statement_timeout=0' psql -AqXt -c"SELECT count(*) FROM pg_stat_activity"`
# The result of the command psql -AqXt –d postgres -c "SELECT count(*) FROM pg_stat_activity" is assigned to a bash variable. 
#The options -AqXt, as discussed previously, cause psql to return only the result without any decoration, as follows:
psql -AqXt -c "SELECT count(*) FROM pg_stat_activity"
1

```
