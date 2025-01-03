---
title: "React 17.0.2"
description: 版本有风险，升级请谨慎
date: 2021-03-29T17:02:01+08:00
tags: [
    "reactjs",
    "babel/core",
]
categories: [
    "开发",
]
cover:
  image: react-17.jpeg
draft: false
---

今天看到react 17.0.2 发布一个礼拜了(快有1年没大的更新了），想升级试一试，在项目下执行 `npm update`指令，结果报错如下：

```shell
✗ npm update
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! 
npm ERR! Found: @babel/core@7.12.3
npm ERR! node_modules/@babel/core
npm ERR!   @babel/core@"7.12.3" from the root project
npm ERR!   @babel/core@"^7.9.0" from @svgr/webpack@5.4.0
npm ERR!   node_modules/@svgr/webpack
npm ERR!     @svgr/webpack@"5.4.0" from the root project
npm ERR!   9 more (babel-jest, babel-loader, ...)
npm ERR! 
npm ERR! Could not resolve dependency:
npm ERR! peer @babel/core@"^7.13.0" from @babel/plugin-bugfix-v8-spread-parameters-in-optional-chaining@7.13.12
npm ERR! node_modules/@babel/preset-env/node_modules/@babel/plugin-bugfix-v8-spread-parameters-in-optional-chaining
npm ERR!   @babel/plugin-bugfix-v8-spread-parameters-in-optional-chaining@"^7.13.12" from @babel/preset-env@7.13.12
npm ERR!   node_modules/@babel/preset-env
npm ERR!     @babel/preset-env@"^7.9.5" from @svgr/webpack@5.4.0
npm ERR!     node_modules/@svgr/webpack
npm ERR!       @svgr/webpack@"5.4.0" from the root project
npm ERR! 
npm ERR! Fix the upstream dependency conflict, or retry
npm ERR! this command with --force, or --legacy-peer-deps
npm ERR! to accept an incorrect (and potentially broken) dependency resolution.
npm ERR! 
npm ERR! See /Users/r/.npm/eresolve-report.txt for a full report.

npm ERR! A complete log of this run can be found in:
npm ERR!     /Users/r/.npm/_logs/2021-03-30T08_44_22_160Z-debug.log

```

这个项目运行过 `npm run eject`，所以担心是eject造成的。

于是在另外一个目录执行`npx create-react-app abc`命令做来一个对照组。


把`abc`项目eject后发现npm install依然会失败。


google发现有类似的[遭遇](https://www.gitmemory.com/issue/facebook/create-react-app/10738/807720421)
> Humm, if I see things correctly, the resolving dependency error occurs because create-react-app has the "@babel/core": dependency fixed to "7.12.3" in its "packages.json" file. 3 days ago, @babel/plugin-bugfix-v8-spread-parameters-in-optional-chaining was merged to Babe master branch that requires "@babel/core" dependency to be "7.13.0" or greater. I don't know create-react-app too well, but would perhaps relaxing the "@babel/core" dependency to "^7.12.3" be a proper way to fix this issue?

 

修改package.json文件，添加"@babel/core": "7.13.14", 依赖，重新npm install 恢复正常。

一下是完整的package.json文件，供参考:

```json
{
  "name": "abc",
  "version": "0.1.0",
  "private": true,
  "proxy": "http://localhost:8080",
  "dependencies": {
    "@babel/core": "7.13.14",
    "@material-ui/core": "^4.11.3",
    "@material-ui/icons": "^4.11.2",
    "@pmmmwh/react-refresh-webpack-plugin": "0.4.3",
    "@svgr/webpack": "5.5.0",
    "@testing-library/jest-dom": "^5.11.10",
    "@testing-library/react": "^11.2.5",
    "@testing-library/user-event": "^12.8.3",
    "@tinymce/tinymce-react": "^3.12.1",
    "@typescript-eslint/eslint-plugin": "^4.5.0",
    "@typescript-eslint/parser": "^4.5.0",
    "babel-eslint": "^10.1.0",
    "babel-jest": "^26.6.0",
    "babel-loader": "8.1.0",
    "babel-plugin-named-asset-import": "^0.3.7",
    "babel-preset-react-app": "^10.0.0",
    "bfj": "^7.0.2",
    "camelcase": "^6.1.0",
    "case-sensitive-paths-webpack-plugin": "2.3.0",
    "css-loader": "4.3.0",
    "dotenv": "8.2.0",
    "dotenv-expand": "5.1.0",
    "eslint": "^7.11.0",
    "eslint-config-react-app": "^6.0.0",
    "eslint-plugin-flowtype": "^5.2.0",
    "eslint-plugin-import": "^2.22.1",
    "eslint-plugin-jest": "^24.1.0",
    "eslint-plugin-jsx-a11y": "^6.3.1",
    "eslint-plugin-react": "^7.21.5",
    "eslint-plugin-react-hooks": "^4.2.0",
    "eslint-plugin-testing-library": "^3.9.2",
    "eslint-webpack-plugin": "^2.5.2",
    "file-loader": "6.1.1",
    "fs-extra": "^9.0.1",
    "html-react-parser": "^1.2.4",
    "html-webpack-plugin": "4.5.0",
    "identity-obj-proxy": "3.0.0",
    "jest": "26.6.0",
    "jest-circus": "26.6.0",
    "jest-resolve": "26.6.0",
    "jest-watch-typeahead": "0.6.1",
    "js-base64": "^3.6.0",
    "mini-css-extract-plugin": "0.11.3",
    "optimize-css-assets-webpack-plugin": "5.0.4",
    "pnp-webpack-plugin": "1.6.4",
    "postcss-flexbugs-fixes": "4.2.1",
    "postcss-loader": "3.0.0",
    "postcss-normalize": "8.0.1",
    "postcss-preset-env": "6.7.0",
    "postcss-safe-parser": "5.0.2",
    "prismjs": "^1.23.0",
    "prompts": "2.4.0",
    "react": "^17.0.2",
    "react-app-polyfill": "^2.0.0",
    "react-dev-utils": "^11.0.3",
    "react-dom": "^17.0.2",
    "react-hook-form": "^6.15.5",
    "react-refresh": "^0.8.3",
    "react-router-dom": "^5.2.0",
    "resolve": "1.18.1",
    "resolve-url-loader": "^3.1.2",
    "sass-loader": "^10.0.5",
    "semver": "7.3.2",
    "style-loader": "1.3.0",
    "terser-webpack-plugin": "4.2.3",
    "tinymce": "^5.7.1",
    "ts-pnp": "1.2.0",
    "url-loader": "4.1.1",
    "web-vitals": "^1.1.1",
    "webpack": "4.44.2",
    "webpack-dev-server": "3.11.1",
    "webpack-manifest-plugin": "2.2.0",
    "workbox-webpack-plugin": "5.1.4"
  },
  "scripts": {
    "start": "node scripts/start.js",
    "build": "node scripts/build.js",
    "test": "node scripts/test.js"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "jest": {
    "roots": [
      "<rootDir>/src"
    ],
    "collectCoverageFrom": [
      "src/**/*.{js,jsx,ts,tsx}",
      "!src/**/*.d.ts"
    ],
    "setupFiles": [
      "react-app-polyfill/jsdom"
    ],
    "setupFilesAfterEnv": [
      "<rootDir>/src/setupTests.js"
    ],
    "testMatch": [
      "<rootDir>/src/**/__tests__/**/*.{js,jsx,ts,tsx}",
      "<rootDir>/src/**/*.{spec,test}.{js,jsx,ts,tsx}"
    ],
    "testEnvironment": "jsdom",
    "testRunner": "/Users/r/repo/github/blog-fn/node_modules/jest-circus/runner.js",
    "transform": {
      "^.+\\.(js|jsx|mjs|cjs|ts|tsx)$": "<rootDir>/config/jest/babelTransform.js",
      "^.+\\.css$": "<rootDir>/config/jest/cssTransform.js",
      "^(?!.*\\.(js|jsx|mjs|cjs|ts|tsx|css|json)$)": "<rootDir>/config/jest/fileTransform.js"
    },
    "transformIgnorePatterns": [
      "[/\\\\]node_modules[/\\\\].+\\.(js|jsx|mjs|cjs|ts|tsx)$",
      "^.+\\.module\\.(css|sass|scss)$"
    ],
    "modulePaths": [],
    "moduleNameMapper": {
      "^react-native$": "react-native-web",
      "^.+\\.module\\.(css|sass|scss)$": "identity-obj-proxy"
    },
    "moduleFileExtensions": [
      "web.js",
      "js",
      "web.ts",
      "ts",
      "web.tsx",
      "tsx",
      "json",
      "web.jsx",
      "jsx",
      "node"
    ],
    "watchPlugins": [
      "jest-watch-typeahead/filename",
      "jest-watch-typeahead/testname"
    ],
    "resetMocks": true
  },
  "babel": {
    "presets": [
      "react-app"
    ]
  },
  "devDependencies": {
    "babel-plugin-prismjs": "^2.0.1"
  }
}

```

