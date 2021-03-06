CREATE EXTERNAL TABLE accumulo_pushdown(key string, value string) 
STORED BY 'org.apache.hadoop.hive.accumulo.AccumuloStorageHandler'
WITH SERDEPROPERTIES ("accumulo.columns.mapping" = ":rowid,cf:string")
TBLPROPERTIES ("external.table.purge" = "true");

INSERT OVERWRITE TABLE accumulo_pushdown 
SELECT cast(key as string), value
FROM src;

-- with full pushdown
explain select * from accumulo_pushdown where key>'90';

select * from accumulo_pushdown where key>'90';
select * from accumulo_pushdown where key<'1';
select * from accumulo_pushdown where key<='2';
select * from accumulo_pushdown where key>='90';

-- with constant expression
explain select * from accumulo_pushdown where key>=cast(40 + 50 as string);
select * from accumulo_pushdown where key>=cast(40 + 50 as string);

-- with partial pushdown

explain select * from accumulo_pushdown where key>'90' and value like '%9%';

select * from accumulo_pushdown where key>'90' and value like '%9%';

-- with two residuals

explain select * from accumulo_pushdown
where key>='90' and value like '%9%' and key=cast(value as int);

select * from accumulo_pushdown
where key>='90' and value like '%9%' and key=cast(value as int);


-- with contradictory pushdowns

explain select * from accumulo_pushdown
where key<'80' and key>'90' and value like '%90%';

select * from accumulo_pushdown
where key<'80' and key>'90' and value like '%90%';

-- with nothing to push down

explain select * from accumulo_pushdown;

-- with a predicate which is not actually part of the filter, so
-- it should be ignored by pushdown

explain select * from accumulo_pushdown
where (case when key<'90' then 2 else 4 end) > 3;

-- with a predicate which is under an OR, so it should
-- be ignored by pushdown

explain select * from accumulo_pushdown
where key<='80' or value like '%90%';

explain select * from accumulo_pushdown where key > '281' 
and key < '287';

select * from accumulo_pushdown where key > '281' 
and key < '287';

set hive.optimize.ppd.storage=false;

-- with pushdown disabled

explain select * from accumulo_pushdown where key<='90';
