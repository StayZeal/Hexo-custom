---
title: Mysql 存储过程+Mybatis调用实现插入操作例子
date: 2014-10-11 17:32:58
tags:
     - Java
     - MySql
     - MyBatis
---
博客地址：http://blog.stayzeal.cn

一、

简介：网上关于存储过程的使用有很多的例子，但大多实现的功能比较简单，由于本人对SQL语句还不是很熟悉，更别说存储过程了，所以在实现该例子的时候遇到了很多问题，现在拿给大家来分享。

在本例子中`mysql +spring +Mybatis` 环境已经搭建好了，下面的例子不是完整的代码，但是遇到的问题和解决办法都会给大家详细描述出来，希望在大家遇到问题是能给大家一些灵感。
<!--more-->
问题介绍：
1、涉及三个表的操作b1,b2,b3,根据查询条件从b1、b2中查出结果并  批量 插入到b3中；
2、查询条件从前台获得，包含多条插入数据的查询条件，由于mysql存储过程不支持数组和链表，所以要用到字符串的拆分，又因为是多条数据，所以要批量插入;

二、

  1、在Mybatis中使用：
```
 <insert id="insertEntitlement"  statementType="CALLABLE"  parameterType="map" >
 {
     call entitlement_op(#{jurisdictionId:INTEGER},#{firmId:INTEGER},#{ids:VARCHAR},",")
 }
</insert>
 // statementType="CALLABLE"  用来标识是调用存储过程；多个参数用Map传递
```
 2、存储过程 `entitlement_op`，参数：`IN jurisdictionId int,IN firmId int,IN entitlementIds VARCHAR(1000),IN split_str VARCHAR(5)`

```
BEGIN

  declare cnt int default 0;
  declare i int default 0;
  set cnt = func_split_TotalLength(entitlementIds ,split_str );

  WHILE i<cnt   #插入多条数据
  DO
    SET i=i+1;

  INSERT
		INTO loa_entitlement (
      FIRM_ID,
		  JURISDICTION_ID,
		  ENTITLEMENT_NAME,
		  ENTITLEMENT_DESC,
		  IS_SHARABLE,
		  IS_PAID_LEAVE,
		  COLOR,
		  PATTERN,
		  LIBRARY,
		  CREATOR,
		  CREATE_TIME
		)
     SELECT
        firmId,#来自参数中，而不是查询结果中
        j.JURISDICTION_ID,
        s.ENTITLEMENT_NAME,
        s.ENTITLEMENT_DESC,
        s.IS_SHARABLE,
        s.IS_PAID_LEAVE,
        s.COLOR,
        s.PATTERN,
        s.LIBRARY,
        s.CREATOR,
        s.CREATE_TIME
     FROM jurisdiction j,sas_loa_entitlement s
     WHERE
       s.jurisdiction_id = j.jurisdiction_id
        AND
          j.jurisdiction_id=jurisdictionId
       AND
          s.entitlement_id =func_split(entitlementIds ,split_str,i);

    END WHILE;

END
```
存储过程中用到的方法：
1、`func_split(f_string varchar(1000),f_delimiter varchar(5),f_order int)`
 - 作用： 用来分割字符串，实现存储过程传递多条数据的功能（摘自网络）
```
BEGIN
        declare result varchar(255) default '';
        set result = reverse(substring_index(reverse(substring_index(f_string,f_delimiter,f_order)),f_delimiter,1));
        return result;
END
```
2、`func_split_TotalLength (f_string varchar(1000),f_delimiter varchar(5))`
-  作用：判断数据总共有多少条
```
BEGIN
    return 1+(length(f_string) - length(replace(f_string,f_delimiter,'')));
END
```
结束：表结构就不给大家介绍了，本来也不是完整的实例，剩下就可以通过spring调用了。
