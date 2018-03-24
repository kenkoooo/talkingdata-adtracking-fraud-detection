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
\copy test_supplement from '/home/ubuntu/talkingdata-adtracking-fraud-detection/data/test_supplement.csv' DELIMITER ',' CSV HEADER;

-- テーブルからコピー
INSERT INTO click_data (click_id,ip,app,device,os,channel,click_time) SELECT click_id,ip,app,device,os,channel,click_time FROM test_data;

-- CONFITIONING
-- ip ごとのクリック数（何回目）を集計して保存する
CREATE TABLE click_count_by_ip AS SELECT id, rank() over (partition by ip order by click_time, id) from click_data;

-- id に PK 貼る
ALTER TABLE click_count_by_ip ADD PRIMARY KEY (id);
