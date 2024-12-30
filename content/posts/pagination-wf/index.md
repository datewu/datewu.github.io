---
title: "准确的分页"
description: 分页要准，就用窗口函数
date: 2020-03-02T11:00:52+08:00
tags: [
    "sql",
    "window function",
    "pagination",
    "react",
]
categories: [
    "开发",
]
cover:
  image: available-paginations.png
draft: false
---

昨天同事调试前端页面分页功能时， 发现了一个分页的问题。

问题简要描述如下：

前端选择一些过滤条件（a&&b&&c||d ...）向后端请求数据，过一会发现用同样的过滤条件去查询，数据变少了，前端看上去第一页和最后一页是一样的。

初步怀疑是分页出了问题。

这个分页的问题比较麻烦，不能稳定复现，一会出现一会又不出现。

分析了很长一段时间后，发现是后台的定时任务更新了db数据使得很多数据不再符合前面的过滤条件，后端框架返回的总页码数，和data的数量不符。

也就是说后端返回的总页码数是脏/旧数据。

## 脏数据
查看后端框架代码时候，发现后端查询db的执行了`count` 和 `select` 两条query：
```sql
select count(*) form table_name where condition_a
-- meamwhile other workers update table_a 
-- A LOT in short time
-- or they(the workers) MIGHT lock 
-- the WHOLE table for READ
select * form table_name where condition_a
```

这就是是造成脏数据的原因。

## 解决方案
### window function
可以用 window function 做到上述两条query的同时查询（其实就是一条查询）：
```sql
SELECT *, count(*) OVER() AS full_count
FROM   tbl
WHERE  --  /* whatever */
ORDER  BY col1
LIMIT  ?
OFFSET ?
```

### Common Table Expressions (cte)

> However, as Dani pointed out, when OFFSET is at least as great as the number of rows returned from the base query, no rows are returned. So we also don't get full_count.

> If that's not acceptable, a possible workaround to always return the full count would be with a CTE and an OUTER JOIN:

参考[Run a query with a LIMIT/OFFSET and also get the total number of rows](https://stackoverflow.com/questions/28888375/run-a-query-with-a-limit-offset-and-also-get-the-total-number-of-rows)
```sql
WITH cte AS (
   SELECT *
   FROM   tbl
   WHERE --  /* whatever */
   )
SELECT *
FROM  (
   TABLE  cte
   ORDER  BY col1
   LIMIT  ?
   OFFSET ?
   ) sub
RIGHT  JOIN (SELECT count(*) FROM cte) c(full_count) ON true;

```

