---
title: Ansible
description: ansible目录结构和常用命令备忘录
date: 2016-04-16T11:33:05+08:00
tags: [
    "ansible",
]
categories: [
    "运维",
]
cover:
  image: ansible.png
draft: false
---

本文不定期更新 :)

[A system administrator's guide to getting started with Ansible](https://www.redhat.com/en/blog/system-administrators-guide-getting-started-ansible-fast?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW)
 
## ad-hoc
管理集群的时候，常常来不及写playbooks，只需要执行一些ad-hoc查看某些主机的状态，
或者批量修改/上传配置文件到某些主机。
```shell
ansible all -m copy -a \
'src=dvd.repo dest=/etc/yum.repos.d owner=root group=root mode=0644' -b
```

## playbook
```shell
ansible-playbook -i prod_hosts demo.yml --skip-tag downloaded
```

### host file
```ini
[api]
tt ansible_host=test
tt3 ansible_host=test3
tt8 ansible_host=test8
[db]
pg1 ansible_host=db88
pg2 ansible_host=db98
```

### task
```yaml
# demo.yml
---
- hosts: db
  vars:
    tar_src: "tars/postgres_exporter_v0.4.1_linux-amd64.tar.gz"
    tar_dest: "/usr/bin/"
    service_src: "services/postgres_exporter.service"
    service_dest: "/usr/lib/systemd/system/" # works on centos; ubuntu is '/etc/systemd/system/

  tasks:
  - debug: var=ansible_default_ipv4.address

  - name:  untar to /usr/bin
    unarchive:
      src: "{{ tar_src }}"
      dest: "{{ tar_dest }}"
    become: true

  - name: download and untar prometheus tarball
    tags: downloaded
      unarchive:
        src: "{{ prometheus_tarball_url }}"
        dest: "{{ prometheus_install_path }}"
        copy: no
   
  - name: copy service file
    copy:
      src: "{{ service_src }}"
      dest: "{{ service_dest }}"
    become: true

  - name: ensure node_export is ebalbe and running
    systemd:
      name: postgres_exporter
      enabled: yes
      daemon_reload: yes
      state: started
    become: true
```
