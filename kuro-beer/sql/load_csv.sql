/*----------------------------------------------------------*/
/* data set-up                                              */
/*----------------------------------------------------------*/


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

/*----------------------------------------------------------*/
-- test.csv 受け皿用の一時テーブル作成
CREATE TEMPORARY TABLE t(
  click_id    BIGINT,
  ip          BIGINT NOT NULL,
  app         BIGINT NOT NULL,
  device      BIGINT NOT NULL,
  os          BIGINT NOT NULL,
  channel     BIGINT NOT NULL,
  click_time  TIMESTAMP
);

-- 一時テーブルに展開 
\copy t from '/home/ubuntu/talkingdata-adtracking-fraud-detection/data/test.csv' DELIMITER ',' CSV HEADER;

-- 一時テーブルからコピー 
INSERT INTO click_data (click_id,ip,app,device,os,channel,click_time)
       SELECT click_id,ip,app,device,os,channel,click_time FROM t;

-- 一時テーブル削除 
drop table t;

/*----------------------------------------------------------*/
-- train.csv 受け皿用の一時テーブル作成
CREATE TEMPORARY TABLE t(
  ip          BIGINT NOT NULL,
  app         BIGINT NOT NULL,
  device      BIGINT NOT NULL,
  os          BIGINT NOT NULL,
  channel     BIGINT NOT NULL,
  click_time  TIMESTAMP,
  attributed_time TIMESTAMP,
  is_attributed INT
);

-- 一時テーブルに展開
\copy t from '/home/ubuntu/talkingdata-adtracking-fraud-detection/data/train.csv' DELIMITER ',' CSV HEADER;

-- 一時テーブルからコピー
INSERT INTO click_data (ip,app,device,os,channel,click_time,attributed_time,is_attributed)
       SELECT ip,app,device,os,channel,click_time,attributed_time,is_attributed FROM t;

-- 一時テーブル削除
drop table t;




