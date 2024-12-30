---
title: pip包冲突
description: urllib3 openssl包和系统site-package冲突
date: 2018-03-30T10:21:25+08:00
tags: [
    "python",
    "import",
    "pip",
]
categories: [
    "运维",
]
cover:
  image: pip.png
draft: false
---

遇到一个奇怪的问题执行`certbot`会报错，`moudle conflict`和 `No module`，但是`yum install certbot`的时候没有报错。

```shell
certbot
Traceback (most recent call last):
File "/bin/certbot", line 7, in <module>
from certbot.main import main
File "/usr/lib/python2.7/site-packages/certbot/main.py", line 17, in <module>
from certbot import account
File "/usr/lib/python2.7/site-packages/certbot/account.py", line 17, in <module>
from acme import messages
File "/usr/lib/python2.7/site-packages/acme/messages.py", line 7, in <module>
from acme import challenges
File "/usr/lib/python2.7/site-packages/acme/challenges.py", line 11, in <module>
import requests
File "/usr/lib/python2.7/site-packages/requests/__init__.py", line 58, in <module>
from . import utils
File "/usr/lib/python2.7/site-packages/requests/utils.py", line 32, in <module>
from .exceptions import InvalidURL
File "/usr/lib/python2.7/site-packages/requests/exceptions.py", line 10, in <module>
from .packages.urllib3.exceptions import HTTPError as BaseHTTPError
File "/usr/lib/python2.7/site-packages/requests/packages/__init__.py", line 95, in load_module
raise ImportError("No module named '%s'" % (name,))
ImportError: No module named 'requests.packages.urllib3'

pip install requests urllib3 pyOpenSSL --force --upgrade
certbot
An unexpected error occurred:
VersionConflict: (setuptools 0.9.8 (/usr/lib/python2.7/site-packages), Requirement.parse('setuptools>=1.0'))
pip install --upgrade pip setuptools
certbot
ls


```
## meat
弄了很久决定抛弃`yum`直接使用 `pip`安装certbot，安装完成后，发现不再报错：
```shell
yum install openssl-devel python-devel
pip install --upgrade pip setuptools
pip install certbot
pip install requests urllib3 pyOpenSSL --force --upgrade

certbot -d tab.deoops.com  --manual --preferred-challenges dns certonly
```

## 小结
本来是不想写这篇博文的，估摸着`letsencrypt`官方 迟早会修复certbot rpm包的，结果一等就是两个月，
letsencrypt都没修复 rpm包。

最近多台服务器的`certbot`安装又遇到这个不兼容的问题，每次去其它的服务器上找`command history`有点麻烦，所以记下来方便查找。
