---
title: 挂载硬盘
description: Linux挂盘，扩容等磁盘操作
date: 2019-10-18T10:03:07+08:00
lastmod: 2023-05-25T10:03:07+08:00
tags: [
    "disk",
    "linux",
    "pv",
    "vg",
]
categories: [
    "运维",
]
cover:
  image: disk.jpeg
draft: false
---

## update: more user friendly

```shell
#bin/bash
mustBeRoot() {
    if [ "$(id -u)" != "0" ]; then
        echo "只有root用户才能运行" 1>&2
        echo "当前登录用户`whoami`"
        exit 1
    fi
}

# 数据盘挂载
checkAndMountDataDisk() {
    echo "选择数据盘/分区 ："
    fdisk -l | grep /dev | grep G | cut  -f 1 -d ,
    echo " "
    read -p "请输入硬盘/分区 名：/dev/" -r disk_name
    disk_id=`blkid | grep $disk_name`
    if [ $? -ne 0 ];then
        echo "获取硬盘/分区 $disk_name uuid失败，请检查名称是否准确"
        exit 1
    fi
    disk_path=`echo $disk_id | cut -f 1 -d ':' `
    echo "已选择 $disk_path"
    disk_uuid=`blkid $disk_path | cut -f 2 -d '"' `
    disk_info=`lsblk -f $disk_path | grep $disk_uuid `
    if [ $? -ne 0 ];then
        echo "获取硬盘/分区 $disk_path 详细信息失败，请检查名称是否正确"
        exit 1
    fi
    fs_type=`echo $disk_info | cut -f 2 -d ' '`
    if [ $fs_type != 'ext4' ];then
        echo "硬盘文件系统格式不是ext4。"
        read -p "是否格式化为 ext4？ 输入 y 同意格式化" -r format_ext4
        if [ $format_ext4 != 'y' ];then
            echo "未格式化 $disk_path 文件系统格式，退出安装脚本。"
            exit 1
        fi
        echo "即将格式化 $disk_path 文件系统格式...."
	      mkfs.ext4 $disk_path
    fi
    if [ -d "$1" ];then
        echo "数据盘挂载点/data目录已存在"
    else
        echo "创建数据盘挂载点/data目录"
        mkdir $1
    fi
    mount UUID=$disk_uuid $1
    echo "UUID=$disk_uuid       $1   ext4    defaults          0    0" >> /etc/fstab
    echo "硬盘挂载成功"
}

checkDataMountpoint() {
   echo '挂载数据盘'
   grep "$1" /etc/fstab | grep ext4
    if [ $? -ne 0 ];then
        checkAndMountDataDisk
    else
        echo '数据盘已挂载'
        mount -a
    fi
    cpAndUntar
}

mustBeRoot
checkDataMountpoint ${1-/data}
```

## lsblk
首先使用`lsblk`查看当前系统硬盘挂载的情况
```shell
[root@dev-7 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0     11:0    1 1024M  0 rom
vda    253:0    0   40G  0 disk
└─vda1 253:1    0   40G  0 part /
vdb    253:16   0  200G  0 disk
└─vdb1 253:17   0  200G  0 part
```

## format and mount
格式化硬盘然后挂载到` /media/newdrive` 目录
```shell
### disk_add_new.sh

function set_vars() {
  fs_ty=ext4
  mount_point=/media/newdrive
  #check=`fdisk -l | grep GB | cut -d ':' -f1 | cut -c 6-`
  #new_disk=`echo $check | cut -d ' ' -f 2`
  new_disk=$1
# new_disk=${check##*\ }
}

function make_file_system(){
  mkfs -t $fs_ty $new_disk
}

function get_uuid() {
  uuid_info=`blkid $new_disk`
  uuid=${uuid_info#*UUID}
  id=`echo $uuid | cut -d '"' -f 2`
}

function mount_and_auto_mount() {
  mkdir -p $mount_point
  mount -t $fs_ty $new_disk $mount_point
  grep $id /etc/fstab || echo UUID=$id $mount_point $fs_ty defaults 0 0 >> /etc/fstab
}

function run() {
  set_vars $1
  make_file_system
  get_uuid
  [ ${#id} -gt 30 ] || exit 1
  mount_and_auto_mount
}
run $1

```

### 扩容
```shell
mount_point=/media/newdrive
# check=`fdisk -l | grep GB | cut -d ':' -f1 | cut -c 6-`
# disk=`echo $check | cut -d ' ' -f 2`
disk=$1  # /dev/sdb   sdc
fs_ty=ext4

e2fsck -f $disk
resize2fs $disk

mount -t $fs_ty $disk $mount_point
```

## 逻辑卷
### 创建逻辑卷
```shell
pvcreate /dev/vdb
vgcreate vg02 /dev/vdb

lvcreate -l 90%free -n kubelet vg02
mkfs.xfs -n ftype=1 /dev/vg02/kubelet

mount /dev/vg02/kubelet /var/lib/kubelet
echo "/dev/mapper/vg02-kubelet /var/lib/kubelet xfs defaults 0 0 " >> /etc/fstab 
```

### 扩容逻辑卷
```shell
# 1. 删除未挂载的逻辑卷
 lvremove vg02/kubelet # lvremove vg02
# 2. 删除kubelet的磁盘
  vgreduce vg02 /dev/vdb # vgremove vg02
# 3. 将原来的磁盘加到别的vg
  vgextend vg01 /dev/vdb
# 4. 扩容逻辑卷
  lvextend -L +200G /dev/vg01/var
# 5. 生效
  xfs_groups /dev/vg01/var
# 6. 删除/etc/fstab 中kubelet的挂载点
## vim /etc/fstab +5dd
```

### troubleshoot
有时候删除逻辑卷会遇到报错`Logical volume vg01/LVgdb contains a filesystem in use`
```shell
[root@cnsz92vl14311 ~]# umount /dev/vg01/LVgdb 
[root@cnsz92vl14311 ~]# lvremove /dev/vg01
Do you really want to remove active logical volume LVgdb? [y/n]: y
  Logical volume "LVgdb" successfully removed
[root@cnsz92vl14311 ~]# lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vda           252:0    0   60G  0 disk 
├─vda1        252:1    0  476M  0 part /boot
└─vda2        252:2    0 59.5G  0 part 
  ├─vg00-root 253:0    0   10G  0 lvm  /
  ├─vg00-home 253:1    0  500M  0 lvm  /home
  ├─vg00-var  253:2    0   10G  0 lvm  /var
  ├─vg00-tmp  253:3    0   10G  0 lvm  /tmp
  └─vg00-app  253:4    0   29G  0 lvm  /app
vdb           252:16   0  300G  0 disk 
[root@cnsz92vl14311 ~]# 
```
