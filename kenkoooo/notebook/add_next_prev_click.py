import pandas as pd
import numpy as np
import gc
from logzero import logger


def create_next_prev(df, column, second="epoctime") -> pd.DataFrame:
    logger.info("sorting...")
    df.sort_values(by=[column, second], inplace=True)
    logger.info("sorted")
    prev_column = "prev_click_second_{}".format(column)
    next_column = "next_click_second_{}".format(column)

    df[prev_column] = df[second] - df[second].shift(+1)
    df["tmp"] = df[column].shift(+1)
    df[prev_column].where(df["tmp"] == df[column], np.nan, inplace=True)
    logger.info("done prev")

    df[next_column] = df[second].shift(-1) - df[second]
    df["tmp"] = df[column].shift(-1)
    df[next_column].where(df["tmp"] == df[column], np.nan, inplace=True)
    logger.info("done next")

    df.drop(columns=["tmp"], inplace=True)
    logger.info("dropped")
    return df


def read_feather(filename: str, nthreads=4) -> pd.DataFrame:
    path = "../data/{}".format(filename)
    return pd.read_feather(path, nthreads=nthreads)


def main():
    df = read_feather("time_table")[["dow"]]
    df["second"] = read_feather("time_of_day")["second_of_day"]
    df["epoctime"] = df["dow"] * 24 * 3600 + df["second"]
    df.drop(columns=["second"], inplace=True)
    logger.info(df.columns)

    df = pd.concat([df, read_feather("multi_basic")], axis=1, copy=False)
    logger.info(df.columns)

    df.drop(columns=['ip_os', 'ip_device', 'ip_app', 'ip_channel', 'os_device', 'os_app',
                     'os_channel', 'device_app', 'device_channel', 'app_channel'], inplace=True)
    logger.info(df.columns)

    columns = ['ip_os_device', 'ip_os_app', 'ip_os_channel', 'ip_device_app',
               'ip_device_channel', 'ip_app_channel', 'os_device_app',
               'os_device_channel', 'os_app_channel', 'device_app_channel',
               #    'ip_os_device_app', 'ip_os_device_channel', 'ip_os_app_channel',
               #    'ip_device_app_channel', 'os_device_app_channel', 'ip_os_device_app_channel'
               ]
    for column in columns:
        logger.info(column)
        df = create_next_prev(df, column)

    logger.info(df.columns)
    df.sort_index(inplace=True)
    df.to_feather("../data/prev_next_click_for_3_columns")


if __name__ == '__main__':
    main()
