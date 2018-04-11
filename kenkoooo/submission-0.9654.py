import gc
import time
import numpy as np
import pandas as pd
from sklearn.cross_validation import train_test_split
import xgboost as xgb
from xgboost import plot_importance
import matplotlib.pyplot as plt
import json
import psycopg2
from logzero import logger

is_valid = False

with open("config.json") as f:
    connection = psycopg2.connect(json.load(f)["psql"])

logger.info("loading train data")

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
train = pd.read_sql_query(train_query, connection)

logger.info("train data loaded")

logger.info("loading test data")

test_query = """
SELECT
    ip,
    app,
    device,
    os,
    channel,
    click_id,
    EXTRACT(DOW FROM click_time) AS dow,
    EXTRACT(DOY FROM click_time) AS doy,
    EXTRACT(DAY FROM click_time) AS day
FROM click_data WHERE click_id IS NOT NULL
"""
test = pd.read_sql_query(test_query, connection)

logger.info("test data loaded")

logger.info("conditioning data")

# Drop the IP and the columns from target
y = train['is_attributed']
train.drop(['is_attributed'], axis=1, inplace=True)

# Drop IP and ID from test rows
sub = pd.DataFrame()
sub['click_id'] = test['click_id'].astype('int')
test.drop(['click_id'], axis=1, inplace=True)
gc.collect()

nrow_train = train.shape[0]
merge = pd.concat([train, test])

del train, test
gc.collect()

# Count the number of clicks by ip and app
ip_count = merge.groupby(['ip'])['channel'].count().reset_index()
ip_count.columns = ['ip', 'clicks_by_ip']
merge = pd.merge(merge, ip_count, on='ip', how='left', sort=False)
merge['clicks_by_ip'] = merge['clicks_by_ip'].astype('uint16')
merge.drop('ip', axis=1, inplace=True)

train = merge[:nrow_train]
test = merge[nrow_train:]

del test, merge
gc.collect()

gc.collect()

logger.info("XGBoost started")
# Set the params(this params from Pranav kernel) for xgboost model
params = {'eta': 0.6,
          'tree_method': "hist",
          'grow_policy': "lossguide",
          'max_leaves': 1400,
          'max_depth': 0,
          'subsample': 0.9,
          'colsample_bytree': 0.7,
          'colsample_bylevel': 0.7,
          'min_child_weight': 0,
          'alpha': 4,
          'objective': 'binary:logistic',
          'scale_pos_weight': 9,
          'eval_metric': 'auc',
          'nthread': 40,
          'random_state': 99,
          'silent': True}


if (is_valid == True):
    # Get 10% of train dataset to use as validation
    x1, x2, y1, y2 = train_test_split(train, y, test_size=0.1, random_state=99)
    dtrain = xgb.DMatrix(x1, y1)
    dvalid = xgb.DMatrix(x2, y2)
    del x1, y2, x2, y2
    gc.collect()
    watchlist = [(dtrain, 'train'), (dvalid, 'valid')]
    model = xgb.train(params, xgb.DMatrix(x1, y1), 200, watchlist,
                      maximize=True, early_stopping_rounds=25, verbose_eval=5)
    del dvalid
else:
    dtrain = xgb.DMatrix(train, y)
    del train, y
    gc.collect()
    watchlist = [(dtrain, 'train')]
    model = xgb.train(params, dtrain, 15, watchlist,
                      maximize=True, verbose_eval=1)

del dtrain
gc.collect()

logger.info("XGBoost finished")

# Load the test for predict
test = pd.read_sql_query(test_query, connection)
test = pd.merge(test, ip_count, on='ip', how='left', sort=False)
del ip_count
gc.collect()

logger.info("prediction started")

test['clicks_by_ip'] = test['clicks_by_ip'].astype('uint16')
test.drop(['click_id', 'ip'], axis=1, inplace=True)
dtest = xgb.DMatrix(test)
del test
gc.collect()

# Save the predictions
sub['is_attributed'] = model.predict(dtest, ntree_limit=model.best_ntree_limit)
sub.to_csv('xgb_sub.csv', index=False)

logger.info("prediction finished")
