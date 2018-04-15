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


/*--------------------------------------*/
-- モデリング用データ作成
/*--------------------------------------*/
-- テストデータの時刻範囲を確認（現地時刻（UTC+8）を使用）
select max(click_time_local), min(click_time_local)
from click_data
where is_test = 1
;
--          max         |         min         
-- ---------------------+---------------------
--  2017-11-10 23:00:00 | 2017-11-10 12:00:00
-- (1 row)

-- 12:00〜23:00の範囲に絞る．
-- データのはじめの汚いデータを捨てる．
create temporary table tmp_click_data as
    select * from click_data
    where  (extract(day from click_time_local) > 6)
       and ((extract(hour from click_time_local) >= 12  and extract(hour from click_time_local) < 23)
       or  is_test = 1)
    ;
-- SELECT 126743931
-- Time: 225383.048 ms

-- QC
select count(*) from tmp_click_data where is_test = 1;
--   count   
-- ----------
--  18790469
-- (1 row)
-- Time: 78470.500 ms

select min(click_time_local),max(click_time_local) from tmp_click_data where is_test = 0;
--          min         |         max         
-- ---------------------+---------------------
--  2017-11-07 12:00:00 | 2017-11-09 22:59:59
-- (1 row)
-- Time: 29335.247 ms

-- dayレベル，hourレベル，minレベルのカウントデータを作成
create temporary table tmp_count_min as
    select
        A.id,
        B.ip_device_os_dow_hour_min,
        count(*) over(partition by B.ip_device_os_dow_hour_min) as count_click_min
    from
        tmp_click_data A join ip_device_os_dow_hour_min B on A.id = B.id
    ;
-- SELECT 126743931
-- Time: 494517.944 ms

create temporary table tmp_count_hour as
    select
        A.id,
        B.ip_device_os_dow_hour,
        count(*) over(partition by B.ip_device_os_dow_hour) as count_click_hour
    from
        tmp_click_data A join ip_device_os_dow_hour B on A.id = B.id
    ;
-- SELECT 126743931
-- Time: 490665.339 ms


-- 諸々の変数を揃える
create table analysis_data as
    with tab as (
        select
            T0.*,
            T1.ip_device_os_dow_hour,
            T1.count_click_hour,
            T2.count_click_min,
            Row_number() over(partition by ip_device_os_dow_hour
                              order by click_time_local, T0.id) as row_number
        from
            tmp_click_data T0 
                inner join tmp_count_hour T1 on T0.id = T1.id
                inner join tmp_count_min T2 on T0.id = T2.id
    ),
    tab2 as (
        select 
            ip_device_os_dow_hour,
            count(distinct app) as app_variety,
            count(distinct channel) as channel_variety
        from tab
        group by ip_device_os_dow_hour
    )
    select
        A.*,
        extract(hour from A.click_time_local) as click_hour,
        extract(epoch from A.click_time_local - B.click_time_local) as interval_pre,
        extract(epoch from C.click_time_local - A.click_time_local) as interval_post,
        B.app as app_pre,
        C.app as app_post,
        D.app_variety,
        B.channel as channel_pre,
        C.channel as channel_post,
        D.channel_variety
    from tab A
        left outer join tab B on A.row_number = (B.row_number - 1)
        left outer join tab C on A.row_number = (C.row_number + 1)
        left outer join tab2 D on A.ip_device_os_dow_hour = D.ip_device_os_dow_hour
    ;
        










