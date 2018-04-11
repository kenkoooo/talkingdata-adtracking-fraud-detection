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
CREATE TABLE ip_device_os_dow_hour AS SELECT id, ip_device_os_dow*100+hour AS ip_device_os_dow FROM (
    SELECT
        i.id,
        i.ip_device_os_dow,
        EXTRACT(hour FROM d.click_time_local) AS hour
    FROM ip_device_os_dow AS i
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












