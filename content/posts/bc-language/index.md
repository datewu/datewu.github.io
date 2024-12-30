---
title: bc语言
description: unix自带bc数指计算语言
date: 2018-10-22T18:16:25+08:00
tags: [
    "bash",
    "unix",
]
categories: [
    "开发",
]
cover:
  image: calculator.jpeg
draft: false
---

## base
通过修改`ibase`和`obase`可以实现各种进制的转化，比如十进制和二进制和十六进制之间的转换； 
> If you aren’t familiar with conversion between decimal, binary, and hexadecimal formats, you can
use a calculator utility such as bc or dc to convert between different radix representations. For 
example, in bc, you can run the command obase=2; 240 to print the number 240 in binary
(base 2) form.

```shell
#!/bin/bash
❯ bc -q
ibase
10
obase
10

1+ 3 *3
10

obase=2
245
11110101

255
11111111
192
11000000
168
10101000
1
1
172
10101100

obase=16
34
22
172
AC

^D%
```

## syntax
```shell
 bc

 An arbitrary precision calculator language.
 More information: https://manned.org/bc.

 - Start bc in interactive mode using the standard math library:
   bc -l

 - Calculate the result of an expression:
   bc <<< "(1 + 2) * 2 ^ 2"

 - Calculate the result of an expression and force the number of decimal places to 10:
   bc <<< "scale=10; 5 / 3"

 - Calculate the result of an expression with sine and cosine using mathlib:
   bc -l <<< "s(1) + c(1)"
```
