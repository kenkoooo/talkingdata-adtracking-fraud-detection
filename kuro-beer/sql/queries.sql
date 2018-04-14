/*--------------------------------------*/
-- 前処理
/*--------------------------------------*/
-- 現地時間を追加

CREATE TABLE click_data_mod AS
    SELECT 
        *,
        click_time + interval '8 hours' as click_time_local
    FROM click_data
;
DROP TABLE click_data;
ALTER TABLE click_data_mod RENAME TO click_data;
-- SELECT 203694359
-- Time: 687029.122 ms

-- CONDITIONING
-- (ip,device,os) を一意に定める値を生成する
CREATE TABLE ip_device_os AS SELECT id, ip*10000*1000+device*1000+os AS ip_device_os FROM click_data;

-- id に PK 貼る
ALTER TABLE ip_device_os ADD PRIMARY KEY (id);

-- INDEX も貼っておく
CREATE INDEX ON ip_device_os (ip_device_os);


-- ip_device_os_dow を id としたテーブルを作る
-- click_time_localを使用
CREATE TABLE ip_device_os_dow AS SELECT id, ip_device_os*10+dow AS ip_device_os_dow FROM (
    SELECT
        i.id,
        i.ip_device_os,
        EXTRACT(DOW FROM d.click_time_local) AS dow
    FROM ip_device_os AS i
    JOIN click_data AS d ON d.id=i.id
) AS d;
-- SELECT 203694359
-- Time: 877424.021 ms
CREATE INDEX ON ip_device_os_dow (ip_device_os_dow);
-- CREATE INDEX
-- Time: 445356.961 ms
ALTER TABLE ip_device_os_dow ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time: 139857.871 ms


-- ip_device_os_dow_hour を id としたテーブルを作る
CREATE TABLE ip_device_os_dow_hour AS 
    SELECT id, ip_device_os_dow*100+hour AS ip_device_os_dow_hour 
    FROM (
        SELECT
            i.id,
            i.ip_device_os_dow,
            EXTRACT(hour FROM d.click_time_local) AS hour
        FROM ip_device_os_dow AS i
        JOIN click_data AS d ON d.id=i.id
    ) AS d;
-- SELECT 
-- Time:  ms
CREATE INDEX ON ip_device_os_dow_hour (ip_device_os_dow_hour);
-- CREATE INDEX
-- Time:  ms
ALTER TABLE ip_device_os_dow_hour ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time:  ms


-- ip_device_os_dow_hour を id としたテーブルを作る
CREATE TABLE ip_device_os_dow_hour AS 
    SELECT id, ip_device_os_dow*100+hour AS ip_device_os_dow_hour 
    FROM (
        SELECT
            i.id,
            i.ip_device_os_dow,
            EXTRACT(hour FROM d.click_time_local) AS hour
        FROM ip_device_os_dow AS i
        JOIN click_data AS d ON d.id=i.id
    ) AS d;
-- SELECT 
-- Time:  ms
CREATE INDEX ON ip_device_os_dow_hour (ip_device_os_dow_hour);
-- CREATE INDEX
-- Time:  ms
ALTER TABLE ip_device_os_dow_hour ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time:  ms


-- ip_device_os_dow_hour_min を id としたテーブルを作る
CREATE TABLE ip_device_os_dow_hour_min AS 
    SELECT id, ip_device_os_dow_hour*100+minute AS ip_device_os_dow_hour_min 
    FROM (
        SELECT
            i.id,
            i.ip_device_os_dow_hour,
            EXTRACT(minute FROM d.click_time_local) AS minute
        FROM ip_device_os_dow_hour AS i
        JOIN click_data AS d ON d.id=i.id
    ) AS d;
-- SELECT 203694359
-- Time: 556779.560 ms
CREATE INDEX ON ip_device_os_dow_hour_min (ip_device_os_dow_hour_min);
-- CREATE INDEX
-- Time: 461471.528 ms
ALTER TABLE ip_device_os_dow_hour_min ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time: 143240.351 ms


/*--------------------------------------*/
-- 集計
/*--------------------------------------*/
-- ip_device_os_dow_hour_minごとにクリック回数，ダウンロード回数を集計
create table summarize_by_idodhm as
    select
        A.ip_device_os_dow_hour_min,
        count(A.id) as count_click,
        sum(B.is_attributed) as count_attrib,
        sum(B.is_attributed) > 0 as flag_attrib
    from ip_device_os_dow_hour_min A join click_data B 
            on A.id = B.id
    where B.is_test = 0
    group by A.ip_device_os_dow_hour_min    
    ;
-- SELECT 39718603
-- Time: 684423.849 ms

-- QC
select sum(count_click) from summarize_by_idodhm;
--     sum    
-- -----------
--  184903890
--  (1 row)

--Time: 41370.646 ms

















