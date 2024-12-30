---
title: 想写个cms
description: 来，用rails写个cms练练手吧
date: 2013-12-23T13:28:34+08:00
lastmod: 2014-02-16T17:23:52+08:00
tags: [
    "rails",
    "gem",
    "web",
]
categories: [
    "开发",
]
cover:
  image: ror.jpeg
draft: flase
---

`updated at 2014/2/16 坑太大，挑战太多，挑战失败，放弃啦 :)`

看完Ruby On Rails tutorial，感觉热血沸腾。
来吧，少年，来写个CMS吧。

## model
数据库设计
### generate
生成model schema数据模型：

```shell
rails g model App \
title:string icon:binary descript:text \
get_url:string hits:integer downloaded:integer score:decimal \
version:string require_os_version:string author:references

rails g model Author name:string descript:text website:string
```
### populate
填充假数据，便于测试。
[faker gem](https://github.com/stympy/faker)

```ruby
#db/seed.rb
30.times do |n|
  ne = Faker::App.author
  dt = Faker::Lorem.paragraph
  we = Faker::Internet.url
  Author.create!(name:     ne,
               descript:   dt,
               website:    we )
end


users = Author.order(:created_at).take(17)
50.times do
      users.each do |u|
        te = Faker::App.name
        dt = Faker::Hacker.say_something_smart
        gu = Faker::Internet.url
        hs = Faker::Number.number(5)
        dd = Faker::Number.number(4)
        se = Faker::Commerce.price
        vn = Faker::App.version
        rn = "android 1.6+ | ios 6.0+"
            u.apps.create!(icon:      nil, title:     te,
                           descript:  dt,  get_url:   gu,
                           hits:      hs,  downloaded: dd,
                           score:     se,  version:   vn,
                    require_os_version: rn)
      end
end

```


### 数据录入
1. 手动/人工录入
form表单
2. 机器抓取
[nokogiri gem](https://github.com/sparklemotion/nokogiri)

## UI/static_pages_controller
### controller
新建controller
```shell
rails g controller StaticPages index
rails g controller Apps update destroy
#destroy widget
rails d controller widgets
rails d model Widget
```
### scss
调整scss
```gemfile
# 修改gemfile
gem 'bootstrap-will_paginate'
gem 'will_paginate'
gem 'bootstrap-sass'
```
rename scss文件
```shell
mv path/to/application.css  path/to/application.scss
```

```scss
@import "bootstrap-sprockets";
@import "bootstrap";

/* mixins, variables, etc. */

$gray-medium-light: #eaeaea;

@mixin box_sizing {
              -moz-box-sizing:    border-box;
              -webkit-box-sizing: border-box;
              box-sizing:         border-box;
}


 /* universal */
html {
  overflow-y: scroll;
}

body {
  padding-top: 60px;
}
            /*  .......   */
```
### erb
添加title自定义支持
```ruby
# application.html.erb添加
<title><%= full_title(yield(:title)) %></title>

# static_pages_helper.rb添加
def full_title(page_title = '')
      base_title = "LOL"
      if page_title.empty?
        base_title
      else
        "#{page_title} | #{base_title}"
      end
end
```

### action
编辑index action
```ruby
# static_pages_controller.rb
def index
      App.per_page = 8
  @apps = App.paginate(page: params[:page])
end

# views/static_pages/insex.html.erb
<% provide(:title, "All apps") %>  # 页面标题
<%= render @apps %>
<%= will_paginate @apps %>

# views/apps/_app.html.erb
<span> <%= app.title %> *  * </span>
```
