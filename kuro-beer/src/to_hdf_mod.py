import pandas as pd
import time
import os
import gc
print(os.getcwd())
path = '../../data/'
start_time = time.time()

key = 'analysis_data'
df = pd.read_csv(path + key + ".csv")
df.to_hdf(path + key + ".hdf", key=key)

del df
gc.collect()

print('[{}] Start to load data'.format(time.time() - start_time))
df = pd.read_hdf(path + key + '.hdf', key=key)

print(df.shape)
print(df.head())
