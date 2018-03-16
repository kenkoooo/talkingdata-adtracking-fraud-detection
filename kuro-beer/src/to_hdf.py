import pandas as pd
import time

path = '../../data/'
dtypes = {
        'ip'            : 'uint32',
        'app'           : 'uint16',
        'device'        : 'uint16',
        'os'            : 'uint16',
        'channel'       : 'uint16',
        'is_attributed' : 'uint8',
        'click_id'      : 'uint32'
        }

train_columns = ['ip', 'app', 'device', 'os', 'channel', 'click_time', 'is_attributed']
test_columns  = ['ip', 'app', 'device', 'os', 'channel', 'click_time', 'click_id']
start_time = time.time()


key = 'test'
df = pd.read_csv(path + key + ".csv",
                 dtype=dtypes,
                 usecols=test_columns)
df.to_hdf(path + key + ".hdf", key=key)

key = 'train'
df = pd.read_csv(path + key + ".csv",
                 dtype=dtypes,
                 usecols=train_columns)
df.to_hdf(path + key + ".hdf", key=key)

key = 'sample'
df = pd.read_csv(path + 'train_sample' + ".csv",
                 dtype=dtypes,
                 usecols=train_columns)
df.to_hdf(path + key + ".hdf", key=key)

print('[{}] Start to load data'.format(time.time() - start_time))
test = pd.read_hdf(path + "test.hdf", key="test")
print('[{}] Finished to load test'.format(time.time() - start_time))
sample = pd.read_hdf(path + "sample.hdf", key="sample")
print('[{}] Finished to load train'.format(time.time() - start_time))
train = pd.read_hdf(path + "train.hdf", key="train")
print('[{}] Finished to load train'.format(time.time() - start_time))

print(test.shape)
print(test.head())

print(train.shape)
print(train.head())
