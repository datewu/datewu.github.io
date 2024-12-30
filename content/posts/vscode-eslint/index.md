---
title: 配置vscode eslint
description: 用airbnb的eslint
date: 2018-04-16T16:34:09+08:00
tags: [
    "vscode",
    "jsx",
    "eslint",
]
categories: [
    "开发",
    "运维",
    "生活",
]
cover:
  image: eslint-airbnb.jpeg
draft: false
---

离职一段时间了，需要自己写点前端代码。
奈何`vim`的js插件对`jsx`的支持不太友好，所以转向`vscode`写点`jsx`。

写了些`react app`代码后，`IDE`到处飘红色的波浪线〰️〰️〰️，很是恼人。

全局配置`react eslint`好多了， 记录下配置的过程备查。

## 配置
基本上是用了`airbnb`的配置：

具体的步骤很简单，两步就好了：
1. npm安装eslint和要用到plugin；
2. 根据需求配置全局的`eslintrc`文件

### plugin
```shell
npm install -g jshint

npm install -g eslint eslint-config-airbnb-base eslint-plugin-import
vi .eslintrc.js
ls -alh /usr/local/bin/npm
ls /usr/local/lib/node_modules/eslint-config-airbnb-base
npm link eslint-config-airbnb-base
ls node_modules
npm link eslint-plugin-import
npm i -g eslint-plugin-react
npm i -g eslint-plugin-jsx-a11y
npm link eslint-plugin-jsx-a11y eslint-plugin-react
vi .eslintrc.js
```

### .elinttc.js
```js
// ~/.eslintrc.js
module.exports = {
parser: "babel-eslint",
"plugins": ["react"],
"extends": [
"airbnb-base",
"eslint:recommended",
"plugin:react/recommended",
],
"rules": {
// "no-unused-vars":0,
"no-console": 'off',
"max-len": [1,120,2,{ignoreComments: true}]
// "prop-types": [2]
},
"env": {
"browser": true,
"node": true,
"jasmine": true
}
};
```

## 参考

[react eslint webpack babel](https://www.robinwieruch.de/react-eslint-webpack-babel/)

[Use ESLint Like a Pro with ES6 and React](http://www.zsoltnagy.eu/use-eslint-like-a-pro-with-es6-and-react/)
