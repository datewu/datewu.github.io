---
title: "nopCloser函数"
description: 如何多次读resp.Body
date: 2019-04-17T21:39:31+08:00
lastmod: 2021-08-17T21:39:31+08:00
tags: [
    "golang",
    "http",
]
categories: [
    "开发",
    "测试",
]
cover:
  image: nopcloser.png
draft: false
---
update: `ioutil`逐渐被`io` 取代。
```go
package ioutil // import "io/ioutil"

func NopCloser(r io.Reader) io.ReadCloser
    NopCloser returns a ReadCloser with a no-op Close method wrapping the
    provided Reader r.

    As of Go 1.16, this function simply calls io.NopCloser.



package io // import "io"

func NopCloser(r Reader) ReadCloser
    NopCloser returns a ReadCloser with a no-op Close method wrapping the
    provided Reader r.
```

最近使用[baloo](https://github.com/h2non/baloo)写集成测试，遇到了个需求，
在`unmarshal`respones之后（或者之前）还要再输出一次response的纯文本格式供debug参考。

即需要多次读http.Resp.Body。

## 问题
response.Body 只能读一次，读完之后再进行read操作就会遇到`EOF` error。


## 分析问题
模糊记得`baloo`在一次请求中能多次(`JSON()` 和 `String()`)读取response.Body内容。

仔细去看了下`baloo`的源代码，发现`baloo`自己在内部 封装了一个对象 `http.RawResonse` ，使用了 `iouti.NopCloser`函数重新填充了`res.Body`:

```go
func readBodyJSON(res *http.Response) ([]byte, error) {
    body, err := ioutil.ReadAll(res.Body)
    if err != nil {
        return []byte{}, err
    }

    // Re-fill body reader stream after reading it
    res.Body = ioutil.NopCloser(bytes.NewBuffer(body))
    return body, err
}
```

## 解决方案

有了` ioutil.NopCloser`函数，可以很快速的写出`debugPlugin`：

```go
func debugPlugin() (p plugin.Plugin) {
    f := func(ctx *context.Context, h context.Handler) {
        res, err := ioutil.ReadAll(ctx.Response.Body)
        fmt.Println("response:", string(res), err, "response Type:", ctx.Response.Header.Get("Content-Type"))

        // should CLOSE, due to next Close method will be no-op
        ctx.Response.Body.Close() 
        ctx.Response.Body = ioutil.NopCloser(bytes.NewBuffer(res))
        h.Next(ctx)
    }
    p = plugin.NewResponsePlugin(f)
    return
}

```
注意：应该先 `resp.Body.Close()` 掉，然后重新填充reader。

因为新的`Response.Body.Close()`是 `no-op`操作，不会去close 之前的Body，可能会造成资源泄漏。

