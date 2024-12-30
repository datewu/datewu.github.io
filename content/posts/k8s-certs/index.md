---
title: "替换k8s所有证书"
description: 更换麻烦所以自签100年
date: 2018-08-10T20:27:10+08:00
tags: [
    "k8s",
    "kubeadm",
    "openssl",
    "makefile",
]
categories: [
    "开发",
    "运维",
]
cover:
  image: k8s.webp
draft: false
---

客户需要把kubernetes `apiserver/etcd/kubelet/kubectl` 等所有的证书有效期修改为100年。

很明显这是一个不合理的需求，不过客户说什么就是什么。

于是经几天的调试有了下面的这个 `Makefile`批量生成所有(`FILES`变量)的证书。

如果对makefile的语法不熟悉，可以看看[Makefile简介](/posts/makefile-tutorial/)

## makefile

```makefile
FILES = ca.crt ca.key sa.key sa.pub front-proxy-ca.crt front-proxy-ca.key etcd_ca.crt etcd_ca.key 
CONFS = admin.conf controller-manager.conf kubelet.conf scheduler.conf
SELFS = kubelet.crt.self kubelet.crt.key
#KEYs = ca.key front-proxy-ca.key etcd_ca.key sa.key
#CAs = ca.crt front-proxy-ca.crt etcd_ca.crt
#PUBs = sa.pub

## kubernetes will sign certificate 
## automatically, so below
## csr/cert is for test purpose
#CSR = apiserver.csr apiserver-kubelet-client.csr 
CERT_KEYS = apiserver.key apiserver-kubelet-client.key front-proxy-client.key
CERTS = apiserver.cert apiserver-kubelet-client.cert front-proxy-client.cert

# openssl genrsa -des3 -out rootCA.key 4096
CMD_CREATE_PRIVATE_KEY = openssl genrsa -out $@ 2048
CMD_CREATE_PUBLIC_KEY = openssl rsa -in $< -pubout -out $@

# openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
CMD_CREATE_CA = openssl req -x509 -new -nodes -key $< -sha256 -days 36500 -out $@ -subj '/CN=kubernetes'
# openssl req -new -key mydomain.com.key -out mydomain.com.csr
CMD_CREATE_CSR = openssl req -new -key $< -out $@ -config $(word 2,$^)
# openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256
CMD_SIGN_CERT = openssl x509 -req -in $< -CA $(word 2,$^) -CAkey $(word 3,$^) -CAcreateserial -out $@ -days 36500 -sha256 -extfile $(word 4,$^) -extensions my_extensions

# generata self sign certificate
CMD_CREATE_CERT = openssl req -x509 -new -nodes -key $< -sha256 -days 36500 -out $@ -subj '/CN=nodeXXX@timestamp1531732165'

CMD_MSG = @echo generating $@ ...

MASTER_IP := 192.168.1.200 ## REMEMBER CHANGE ME

.PHONY: all clean check self_sign rename

all: ${FILES} ${CONFS} ${CERT_KEYS} ${CERTS}

clean:
    -rm ${FILES} ${CONFS} ${CERT_KEYS} ${CERTS}

self_sign: ${SELFS}

check:
    for f in *.cert *.crt; do echo $$f; openssl x509 -noout -dates -in $$f; echo '==='; done

rename:
    for f in *.cert; do echo $$f; mv $$f $${f%.*}.crt; echo '====='; done

%.key:
    ${CMD_MSG}
    ${CMD_CREATE_PRIVATE_KEY}

%.pub: %.key
    ${CMD_MSG}
    ${CMD_CREATE_PUBLIC_KEY}

%.self: %.key
    ${CMD_MSG}
    ${CMD_CREATE_CERT}

%.crt: %.key
    ${CMD_MSG}
    ${CMD_CREATE_CA}

%.csr: %.key %.csr.cnf
    ${CMD_MSG}
    ${CMD_CREATE_CSR}

%.cert: %.csr ca.crt ca.key %.csr.cnf
#%.cert: %.csr front-proxy-ca.crt front-proxy-ca.key %.csr.cnf
    ${CMD_MSG}
    ${CMD_SIGN_CERT}

%.conf: %.cert %-conf.sh
    sh $(word 2,$^) ${MASTER_IP}

```

上面的`Makefile`还需要对应的`csr`和 `conffiles`。

###  admin.csr.cnf

```shell
cat <<EOF > admin.conf
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat ca.crt | base64 | tr -d '\n')
    server: https://$1:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: $(cat admin.cert | base64 | tr -d '\n')
    client-key-data: $(cat admin.key | base64 | tr -d '\n')
EOF


```

### admin-conf.sh

```ini
[ req ]
prompt = no
utf8 = yes
distinguished_name = my_req_distinguished_name
req_extensions = my_extensions

[ my_req_distinguished_name ]
C = dn
ST = lol
L = dota
O  = system:masters # change this
CN = kubernetes-admin # change this

[ my_extensions ]
basicConstraints=CA:FALSE
subjectKeyIdentifier = hash
#  subjectAltName=@my_subject_alt_names
#  
#  [ my_subject_alt_names ]
#  DNS.1 = *.oats.org
#  DNS.2 = *.oats.net
#  DNS.3 = *.oats.in
#  DNS.4 = oats.org
#  DNS.5 = oats.net
#  DNS.6 = oats.in
```

## kubeadm

 安装k8s集群的时候，使用`kubeadm phase certs`命令更新证书即可：

```shell
kubeadm alpha phase certs all --config kubeadm-config.yaml
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config.yaml
kubeadm alpha phase kubelet write-env-file --config kubeadm-config.yaml
kubeadm alpha phase kubeconfig kubelet --config kubeadm-config.yaml

kubeadm alpha phase kubeconfig all --config kubeadm-config.yaml

## --experimental-cluster-signing-duration=187600h0m0s
kubeadm alpha phase controlplane all --config kubeadm-config.yaml

systemctl start kubelet
kubeadm alpha phase mark-master --config kubeadm-config.yaml

## kubeadm join 172.16.0.5:6443 --token xvrmo8.lk0ec7ifzn8mdflu2  --discovery-token-unsafe-skip-ca-verification
```
