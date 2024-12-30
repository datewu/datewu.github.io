---
title: "调度到master节点"
description: 有些pod需要运行在master/etcd节点上
date: 2018-08-18T20:57:52+08:00
tags: [
    "k8s",
    "affinity",
]
categories: [
    "运维",
]
cover:
  image: toleration.webp
draft: false
---

一般来说，kubernetes 的pod是不在master 节点上运行的。

如果要求pod 必须被调度到master 节点上运行，可以修改pod 的 toleration 和 affinity。

## toleration和affinity：
在pod加上toleration和affinity配置

### yaml
```yaml
spec:
  tolerations:
    - key: "node-role.kubernetes.io/master"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-role.kubernetes.io/master
            operator: Exists

```

### go
```go
+                            Operator: apiv1.TolerationOpExists,
+                            Effect:   apiv1.TaintEffectNoSchedule,
+                        },
+                    },
+                    Affinity: &apiv1.Affinity{
+                        NodeAffinity: &apiv1.NodeAffinity{
+                            RequiredDuringSchedulingIgnoredDuringExecution: &apiv1.NodeSelector{
+                                NodeSelectorTerms: []apiv1.NodeSelectorTerm{
+                                    apiv1.NodeSelectorTerm{
+                                        MatchExpressions: []apiv1.NodeSelectorRequirement{
+                                            apiv1.NodeSelectorRequirement{
+                                                Key:      "node-role.kubernetes.io/master",
+                                                Operator: apiv1.NodeSelectorOpExists,
+                                            },
+                                        },
+                                    },
+                                },
+                            },
```
