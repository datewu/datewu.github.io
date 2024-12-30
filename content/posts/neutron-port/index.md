---
title: "Neutron小记"
description: 常见neutron port操作命令
date: 2019-04-21T18:39:27+08:00
tags: [
    "openstack",
    "network",
    "neutron",
    "script",
    "bash",
]
categories: [
    "开发",
    "运维",
]
cover:
  image: Neutron-Networking-CompNet-v1.png
draft: false
---

前段时间的花了很多功夫对接k8s和openstack的kuryr-kubernetes网路组件。
学到了很多openstack的知识，今天抽出时间来整理下。

## client
首先是 install openstack-cli neutron client：
```bash
#!/bin/bash
[root@deoops ~]# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.5 (Maipo)
####  add openstack yum repo source
[root@deoops ~]# vi /etc/yum.repos.d/openstack.repo
[root@deoops ~]# yum install -y   python2-openstackclient  openstack-neutron
[root@deoops shells]# cat source
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=your_project_name
export OS_USERNAME=your_use_name
export OS_PASSWORD=your_pwd
export OS_AUTH_URL=http://10.8.1.3:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

```

### vip
我们来创建一个`virtual IP`验证上一步配置的openstack source对不对 ：

1. 创建 vip 对应的port;
2. 把 上一步创建好的port加入到 vm ip对应port 的 `allow-address-pairs` 属性中;
```shell
[root@deoops shells]# cat vip.sh
. ./source
network=your_network_id

### i've comment out the create Port operation
#subnet=you_subnet_id

#for i in {62..64}
#do
#  echo $i
#  neutron port-create --fixed-ip subnet_id=$subnet,ip_address=10.0.1.$i --device-owner 'Virtual IP' --no-security-groups  --name 'Virtual IP' $network
#done

#  openstack port list   | grep -E '10.0.1.6(2|3|4)'  | cut -d '|' -f 4,5

#p1=mac_address=fa:16:3e:aa:6b:68,ip_address='10.0.1.64'
#p2=mac_address=fa:16:3e:1d:11:2d,ip_address='10.0.1.62'
#p3=mac_address=fa:16:3e:b8:47:f9,ip_address='10.0.1.63'

p1=ip_address='10.0.1.64'
p2=ip_address='10.0.1.62'
p3=ip_address='10.0.1.63'
p4=ip_address='10.0.1.80'

#for p in `neutron port-list  --device-owner compute:nova -f value | grep -E '10.0.1.5(1|2|3)' | cut -d ' ' -f 1 `;
for p in `neutron port-list  --device-owner compute:nova -f value | grep -E '10.0.1' | cut -d ' ' -f 1 `;
do
  echo $p $p1 $p2 $p3 $p4
  ### must NOT set virtual ip Port macaddress
  ### leave it empty to use host port macaddress
  neutron port-update $p  --allowed-address-pair $p1 --allowed-address-pair $p2 --allowed-address-pair $p3 --allowed-address-pair $p4
done

```

### create port
申请创建`port`
```shell
[root@deoops shells]# cat create-port.sh
#!/bin/bash
. ./source
network=your_network_id
subnet=your_subnetwork_id

function setup
{
  #i=$1
  #ip_addr=10.0.1.$((i+1))
  echo "going to create ip ..."
  #neutron port-create --fixed-ip subnet_id=$subnet,ip_address=$ip_addr --device-owner 'compute:kuryr' --no-security-groups  --name 'concurrent load test IP' $network
  neutron port-create subnet_id=$subnet --device-owner 'compute:kuryr' --no-security-groups  --name 'concurrent load test IP lll' $network
}

for i in `seq $1`; do
        time   setup $i &
done
```

### update allow-address-pairs
批量update allow-address-pairs:
```shell
[root@deoops shells]# cat allow-address-pairs-load-test.sh
. ./source
vm_port=vm_port_id
function setup
{
i=$1
mac=$(echo $[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10])
ip_addr=10.0.1.$((i+1))
param+=" --allowed-address-pair ip_address=${ip_addr},mac_address=${mac}"

#echo $vm_port $param
neutron port-update $vm_port $param

}

echo starting
for i in `seq $1`; do ## for i in `jot $1`; do
echo "$i..."
time setup $i
done
```

### delete port & allowed-address-pairs
清理 Port 和 Port allowed-address-pairs
```shell
#!/bin/bash
. ./source
#neutron port-list  --device-owner compute:kuryr
neutron port-delete `neutron port-list  --device-owner compute:kuryr -c id -f value`
neutron port-list  --device-owner compute:nova | grep 10.0.1 | grep -vE '10.0.1.5(1|2|3)'
for p in `neutron port-list  --device-owner compute:nova -f value | grep 10.0.1 | cut -d ' ' -f 1 `; do   neutron port-update $p --allowed-address-pairs action=clear ; done
```

### trunk port
创建trunk 子port
```shell
for  i in `openstack port list | grep ACTIVE |grep -vE '(22.1.104|1.106|132|117|129)'  | awk '{print $2}'`;
 do openstack network trunk unset --subport $i trunktest;
 done

 for  i in `openstack port list | grep DOWN | awk '{print $2}'`;
 do openstack port delete $i ;
 done

############################################

openstack network create —share —external —provider-physical-network provider —provider-network-type vlan —provider-segment 162 podlan162 —transparent-vlan

openstack subnet create —no-dhcp —subnet-range 172.23.0.0/16 —gateway 172.23.0.254   —network podlan162 —allocation-pool start=172.23.1.101,end=172.23.1.201   —dns-nameserver 114.114.114.114 jyvlan162sub2
openstack port create —network podlan162 —fixed-ip subnet=jyvlan162sub2,ip-address=172.23.1.129 —project admin  v162port

# openstack trunk 端口加入
openstack network trunk create —parent-port v162port trunktest

openstack network create —share —external —provider-physical-network provider —provider-network-type vlan —provider-segment 163 podlan163 —transparent-vlan

openstack subnet create —no-dhcp —subnet-range 172.24.0.0/16 —gateway 172.24.0.254   —network podlan163 —allocation-pool start=172.24.1.101,end=172.24.1.201   —dns-nameserver 114.114.114.114 jyvlan164sub2
openstack port create —network podlan163  —fixed-ip subnet=jyvlan164sub2,ip-address=172.24.1.129 —project admin  v163port
openstack network trunk set trunktest —subport port=v163port,segmentation-type=vlan,segmentation-id=163


# 测试子网，测试163 tag

sudo ip link add link eth0 name eth0.163 type vlan id 163
sudo ip link set dev eth0.163 address  fa:16:3e:26:a8:08
sudo ip link set dev eth0.163 up

```

