-- 時間見積もりクエリ
EXPLAIN ANALYZE select max(os) from click_data;
--                                                              QUERY PLAN                                                              
-----------------------------------------------------------------------------------------------------------------------------------
--  Aggregate  (cost=5060926.40..5060926.41 rows=1 width=8) (actual time=153792.391..153792.391 rows=1 loops=1)
--    ->  Seq Scan on click_data  (cost=0.00..4551690.32 rows=203694432 width=8) (actual time=0.014..100829.054 rows=203694359 loops=1)
--  Planning time: 0.098 ms
--  Execution time: 153792.425 ms
-- (4 rows)

-- Time: 153953.446 ms
