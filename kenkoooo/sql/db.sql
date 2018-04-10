-- 
-- SET UP
-- 

-- 全データをまとめたテーブル
CREATE TABLE click_data (
  id          SERIAL PRIMARY KEY,
  click_id    BIGINT,
  ip          BIGINT NOT NULL,
  app         BIGINT NOT NULL,
  device      BIGINT NOT NULL,
  os          BIGINT NOT NULL,
  channel     BIGINT NOT NULL,
  click_time  TIMESTAMP,
  attributed_time TIMESTAMP,
  is_attributed INT
);

-- train 用のテーブル作成
CREATE TABLE train_data(
  ip          BIGINT NOT NULL,
  app         BIGINT NOT NULL,
  device      BIGINT NOT NULL,
  os          BIGINT NOT NULL,
  channel     BIGINT NOT NULL,
  click_time  TIMESTAMP,
  attributed_time TIMESTAMP,
  is_attributed INT
);

-- test 用のテーブル作成
CREATE TABLE test_data(
  click_id    BIGINT PRIMARY KEY,
  ip          BIGINT NOT NULL,
  app         BIGINT NOT NULL,
  device      BIGINT NOT NULL,
  os          BIGINT NOT NULL,
  channel     BIGINT NOT NULL,
  click_time  TIMESTAMP
);

-- test_supplement 用のテーブル作成
CREATE TABLE test_supplement(
  click_id    BIGINT PRIMARY KEY,
  ip          BIGINT NOT NULL,
  app         BIGINT NOT NULL,
  device      BIGINT NOT NULL,
  os          BIGINT NOT NULL,
  channel     BIGINT NOT NULL,
  click_time  TIMESTAMP
);


-- テーブルに展開
\copy train_data from '/home/ubuntu/talkingdata-adtracking-fraud-detection/data/train.csv' DELIMITER ',' CSV HEADER;
\copy test_data from '/home/ubuntu/talkingdata-adtracking-fraud-detection/data/test.csv' DELIMITER ',' CSV HEADER;
-- COPY 18790469
-- Time: 75959.376 ms
\copy test_supplement from '/home/ubuntu/talkingdata-adtracking-fraud-detection/data/test_supplement.csv' DELIMITER ',' CSV HEADER;
-- COPY 57537505
-- Time: 253610.982 ms

-- テーブルからコピー
INSERT INTO click_data (ip,app,device,os,channel,click_time,attributed_time,is_attributed) SELECT ip,app,device,os,channel,click_time,attributed_time,is_attributed FROM train_data;
-- INSERT 0 184903890
-- Time: 856930.007 ms

INSERT INTO click_data (click_id,ip,app,device,os,channel,click_time) SELECT click_id,ip,app,device,os,channel,click_time FROM test_data;
-- INSERT 0 18790469
-- Time: 86929.900 ms

-- CONDITIONING
-- (ip,device,os) を一意に定める値を生成する
CREATE TABLE ip_device_os AS SELECT id, ip*10000*1000+device*1000+os AS ip_device_os FROM click_data;
-- SELECT 203694359
-- Time: 293787.231 ms
-- id に PK 貼る
ALTER TABLE ip_device_os ADD PRIMARY KEY (id);
-- ALTER TABLE
-- Time: 321862.938 ms
-- INDEX も貼っておく
CREATE INDEX ON ip_device_os (ip_device_os);
-- CREATE INDEX
-- Time: 246296.134 ms

-- ip_device_os のクリックが何回目かカウントする
CREATE TABLE click_count_by_ip_device_os AS SELECT i.id, rank() over(partition by ip_device_os ORDER BY click_time, i.id) FROM click_data AS c JOIN ip_device_os AS i ON i.id=c.id;
-- SELECT 203694359
-- Time: 1203880.021 ms
-- id に PK 貼る
ALTER TABLE click_count_by_ip_device_os ADD PRIMARY KEY (id);

-- (app, channel) の相関を見る
CREATE TABLE count_by_app_channel AS select app, channel, count((app, channel)) from click_data group by (app, channel);
-- SELECT 1457
-- Time: 159926.292 ms

-- train の (app, channel) でクリック数とダウンロード数を見る
CREATE TABLE count_attributed AS SELECT SUM(is_attributed) AS count_attributed, COUNT(id) AS count_click, app, channel FROM click_data WHERE is_attributed IS NOT NULL GROUP BY (app, channel);
-- SELECT 1420
-- Time: 160088.186 ms

-- ip_device_os ごとに 1 つずらしたテーブルを作る
CREATE TABLE time_difference1 AS 
SELECT d.id AS id, d2.id AS prev_id, d.click_time-d2.click_time AS time_difference1 
FROM (
  SELECT c.id, c.click_time, cc.rank, i.ip_device_os FROM click_data AS c
  JOIN ip_device_os AS i ON c.id=i.id
  JOIN click_count_by_ip_device_os AS cc ON cc.id=i.id
) AS d
LEFT OUTER JOIN (
  SELECT c.id, c.click_time, cc.rank, i.ip_device_os FROM click_data AS c
  JOIN ip_device_os AS i ON c.id=i.id
  JOIN click_count_by_ip_device_os AS cc ON cc.id=i.id
) AS d2 ON d.rank=d2.rank+1 AND d.ip_device_os=d2.ip_device_os;

-- SELECT 203694359
-- Time: 3350234.482 ms

-- ip_device_os_dow を id としたテーブルを作る
CREATE TABLE ip_device_os_dow AS SELECT id, ip_device_os*10+dow AS ip_device_os_dow FROM (
    SELECT
        i.id,
        i.ip_device_os,
        EXTRACT(DOW FROM d.click_time) AS dow
    FROM ip_device_os AS i
    JOIN click_data AS d ON d.id=i.id
) AS d;
-- SELECT 203694359
-- Time: 648756.319 ms
CREATE INDEX ON ip_device_os_dow (ip_device_os_dow);
-- CREATE INDEX
-- Time: 334411.268 ms
