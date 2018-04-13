import pandas as pd
import json
import psycopg2
from logzero import logger

host="talkingdata2.cxu3byr36ara.ap-northeast-1.rds.amazonaws.com"
with open("config.json") as f:
    password=json.load(f)["pass"]
connection = psycopg2.connect(
    host=host,
    dbname="talkingdata",
    user="talkingdata",
    password=password)
train_query = """
SELECT
    ip,
    app,
    device,
    os,
    channel,
    is_attributed,
    EXTRACT(DOW FROM click_time) AS dow,
    EXTRACT(DOY FROM click_time) AS doy,
    EXTRACT(DAY FROM click_time) AS day
FROM click_data WHERE click_id IS NULL;
"""

logger.info("Start loading")
train = pd.read_sql_query(train_query, connection)
logger.info("Finished")

# /usr/bin/time -f "%M KB" python sql_memory_experiments_pandas.py                                                                     
# [I 180413 05:34:15 sql_memory_experiments_pandas:28] Start loading
# [I 180413 05:50:14 sql_memory_experiments_pandas:30] Finished
# 110256160 KB
