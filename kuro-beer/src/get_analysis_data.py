import psycopg2
import pandas as pd
import numpy as np

path = '../../data/'
cnn_config = {
    "host": "kaggle-talkingdata-adtracking-fraud-detection.civd5r1fqbzl.us-east-2.rds.amazonaws.com",
    "port": "5432",
    "dbname": "kaggle",
    "user": "kurobeer",
    "password": "pass0123"
}
cnn = psycopg2.connect(**cnn_config)
cur = cnn.cursor()
# cnn.get_backend_pid()

# cur.execute('select * from sample;')
# result = cur.fetchall()
# 
# i = 0
# for row in result:
#     print(row)
#     i+=1
#     if i == 10:
#         break

df = pd.read_sql(sql="SELECT id, is_attributed, uq_user, app, channel, cnt_15min FROM click_data_mod", con=cnn)
print(df.shape)
print(df.head())

cur.close()
cnn.close()

key='sample'
df.to_hdf(path + key + ".hdf", key=key)




