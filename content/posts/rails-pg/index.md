---
title: 连接数据库
description: rails数据库配置
date: 2013-11-07T10:06:54+08:00
tags: [
    "rails",
    "postgresql",
    "yaml",
    "web",
]
categories: [
    "开发",
]
cover:
  image: rails-pg.png
draft: flase
---

跟着rails tutorial 学习rails框架时，遇到了db链接的问题
### 问题
```shell
rake db:create failed
   
  PG::ConnectionBad: could not connect to server: No such file or directory
    Is the server running locally and accepting
    connections on Unix domain socket "/var/pgsql_socket/.s.PGSQL.5432"?
```

Google之后发现是database.yml配置文件没有加上`host：localhost`配置项。

过一会，发现PATH没有包含psql命令。
```shell
vi ~/.bash_profile
#添加下面一行内容
export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin:$PATH"
exit

## or
echo export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin:$PATH" >> ~/.zshrc
```
终于`rake db:migrate` 成功。

### 附录
附上database.yml（production环境使用heroku环境变量)
```yaml
default: &default
      adapter: postgresql
      encoding: unicode
      # For details on connection pooling, see rails configuration guide
      # http://guides.rubyonrails.org/configuring.html#database-pooling
      pool: 5

development:
      <<: *default
      host: localhost
      database: xxx_development

test:
      <<: *default
      host: localhost
      database: xxx_test

production:
      <<: *default
      database: xxx
      username: xxx
      password: <%= ENV['xxx_xxx_PASSWORD'] %>
```

