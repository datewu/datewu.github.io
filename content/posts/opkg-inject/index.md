---
title: "脚本注入"
description: 注入shell到opkg
date: 2015-06-18T13:32:58+08:00
tags: [
    "shell",
    "opkg",
    "openwrt",
    "make",
]
categories: [
    "开发",
]
cover:
  image: opkg.png
draft: false
---

使用opkg安装软件时，常常需要对候软件包进行初始化或者自定义化操作，这种开发需求一般写给shell脚本就可以对付了。
现在的问题是当这些脚本多了之后，原作者也不愿意修改安装包，我们怎么分发这些自定义的脚本，能不能把自定义的这些脚本编译到opkg包里？

## 位置
把本地的shell脚本放在openwert 仓库的这个目录，编译openwrt的时候就会被打包到对应opkg二进制文件中：
```shell
/barrier_breaker/package/package-abc    # package makefile文件所在
package-abc/files                      # shell脚本放置目录
```

## 步骤
1. 修改Makefile

在`package`目录下任意找一个package目录，比如`chinadns`,
然后修改Makefile文件。
在install语句后添加 :
```shell
$(INSTALL_BIN) ./files/your_script.sh $(1)/etc/config/your_script.sh
```

2. 放置脚本
将脚本your_script.sh放置在files目录下；

3. 选择opkg 
在make menuconfig 图像界面中选择修改过的包（chinadns）

## 附
package 和注入文件相关的部分`makefile`代码:

```makefile
##
    include $(TOPDIR)/rules.mk  
     PKG_NAME:=xxx
    PKG_RELEASE:=1  
    PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
    PKG_SOURCE_URL:=https://github.com/xxx/releases/download/v$(PKG_VERSION)
    PKG_MD5SUM:=f772a750580243cfxcsfd2xc39d7b9171b1
    PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)  
    include $(INCLUDE_DIR)/package.mk  
##  

    define Package/xxx 
        SECTION:=net  
        CATEGORY:=Network  
        TITLE:=xxx 
    endef  
###   

    define Package/xxx/description
        button haha upgrade.
    endef
###   
    
    #define Package/xxx/conffiles
    #/etc/config/system
    #/etc/hotplug.d/button/00-button
    #endef
###        

    define Package/wps_button/install
        #$(INSTALL_DIR) $(1)/etc/init.d
        $(INSTALL_BIN) ./files/xxx $(1)/etc/config/xxx
        #$(INSTALL_DATA) ./files/system.conf $(1)/etc/config/system
    endef
###  

    $(eval $(call BuildPackage,xxx))

##  


```
