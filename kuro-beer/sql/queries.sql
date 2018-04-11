/*--------------------------------------*/
-- 前処理
/*--------------------------------------*/
-- 現地時間を追加

CREATE TABLE click_data_mod AS
    SELECT 
        id,
        ip,
        app,
        device,
        os,
        channel,
        click_time,
        attributed_time,
        is_attributed,
        is_test,
        click_time + interval '8 hours' as click_time_local
    FROM click_data
;
DROP TABLE click_data;
ALTER TABLE click_data_mod RENAME TO click_data;


-- CONDITIONING
-- (ip,device,os) を一意に定める値を生成する
CREATE TABLE ip_device_os AS SELECT id, ip*10000*1000+device*1000+os AS ip_device_os FROM click_data;
-- SELECT 
-- Time: ??? ms
-- id に PK 貼る
ALTER TABLE ip_device_os ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time:  ms
-- INDEX も貼っておく
CREATE INDEX ON ip_device_os (ip_device_os);
-- CREATE INDEX
-- Time:  ms

-- ip_device_os_dow を id としたテーブルを作る
CREATE TABLE ip_device_os_dow AS SELECT id, ip_device_os*10+dow AS ip_device_os_dow FROM (
    SELECT
        i.id,
        i.ip_device_os,
        EXTRACT(DOW FROM d.click_time) AS dow
    FROM ip_device_os AS i
    JOIN click_data AS d ON d.id=i.id
) AS d;
-- SELECT 
-- Time:  ms
CREATE INDEX ON ip_device_os_dow (ip_device_os_dow);
-- CREATE INDEX
-- Time:  ms
ALTER TABLE ip_device_os_dow ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time:  ms

CREATE TABLE attributed_count_by_ip_device_os_dow AS
SELECT
    COUNT(is_attributed),
    SUM(is_attributed),
    ip_device_os_dow
FROM click_data AS d
JOIN ip_device_os_dow AS i ON i.id=d.id
WHERE is_attributed IS NOT NULL
GROUP BY ip_device_os_dow;
-- SELECT 5804423
-- Time: 638730.846 ms
ALTER TABLE attributed_count_by_ip_device_os_dow ADD PRIMARY KEY (ip_device_os_dow);
-- ALTER TABLE
-- Time: 6048.707 ms










