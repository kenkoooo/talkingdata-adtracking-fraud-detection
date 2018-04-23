import gc
import time
import numpy as np
import pandas as pd
from sklearn.cross_validation import train_test_split
import xgboost as xgb
from xgboost import plot_importance
import matplotlib.pyplot as plt
import click
from logzero import logger


def validate_model(data_name: str, n_thread: int):
    logger.info("Loading HDF...")
    click_data = pd.read_hdf("../data/{}.hdf".format(data_name), data_name)
    logger.info(click_data.dtypes)

    logger.info("Splitting data...")
    click_data.drop(columns=["click_id"], inplace=True)
    train = click_data[click_data["dow"] < 3]
    valid = click_data[click_data["dow"] == 3]

    del click_data
    gc.collect()

    y_train = train["is_attributed"].astype("int")
    train.drop(columns=["is_attributed"], inplace=True)
    y_valid = valid["is_attributed"].astype("int")
    valid.drop(columns=["is_attributed"], inplace=True)
    gc.collect()

    logger.info("Generating matrix...")
    dtrain = xgb.DMatrix(train, y_train)
    dvalid = xgb.DMatrix(valid, y_valid)

    del train, y_train, valid, y_valid
    gc.collect()

    logger.info("Validating...")
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
              'nthread': n_thread,
              'random_state': 99,
              'silent': True}
    watchlist = [(dtrain, 'train'), (dvalid, 'valid')]
    model = xgb.train(params,
                      dtrain,
                      200,
                      watchlist,
                      maximize=True,
                      early_stopping_rounds=25,
                      verbose_eval=5)
    plot_importance(model)
    plt.gcf().savefig('feature_importance_xgb_validation.png')


def get_test_data(data_name: str):
    logger.info("Loading HDF...")
    click_data = pd.read_hdf("../data/{}.hdf".format(data_name), data_name)
    logger.info(click_data.dtypes)

    logger.info("Splitting data...")
    test = click_data[click_data["click_id"].notna()]
    del click_data
    gc.collect()

    sub = pd.DataFrame()
    sub["click_id"] = test["click_id"].astype("int")

    test.drop(columns=["click_id"], inplace=True)
    test.drop(columns=["is_attributed"], inplace=True)
    gc.collect()

    logger.info("Generating matrix...")
    dtest = xgb.DMatrix(test)
    del test
    gc.collect()
    return dtest, sub


def train_model(data_name: str, n_thread: int):
    logger.info("Loading HDF...")
    click_data = pd.read_hdf("../data/{}.hdf".format(data_name), data_name)
    logger.info(click_data.dtypes)

    logger.info("Splitting data...")
    train = click_data[click_data["click_id"].isna()]
    del click_data
    gc.collect()

    train.drop(columns=["click_id"], inplace=True)
    gc.collect()

    y_train = train["is_attributed"].astype("int")
    train.drop(columns=["is_attributed"], inplace=True)
    gc.collect()

    logger.info("Generating matrix...")
    dtrain = xgb.DMatrix(train, y_train)
    del train, y_train
    gc.collect()

    logger.info("Training...")
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
              'nthread': n_thread,
              'random_state': 99,
              'silent': True}
    watchlist = [(dtrain, 'train')]
    model = xgb.train(params, dtrain, 15, watchlist,
                      maximize=True, verbose_eval=1)
    plot_importance(model)
    plt.gcf().savefig('feature_importance_xgb_test.png')

    return model


def generate_submission(data_name: str, n_thread: int):
    model = train_model(data_name, n_thread)

    logger.info("Predicting...")
    dtest, sub = get_test_data(data_name)
    sub['is_attributed'] = model.predict(
        dtest,
        ntree_limit=model.best_ntree_limit)
    sub.to_csv('xgb_sub.csv', index=False)


@click.command()
@click.option('--thread', "-t", default=4, help='number of threads')
@click.option('--validation', "-V", is_flag=True, help="do validation of model")
@click.option('--prediction', "-p", is_flag=True, help="do prediction")
def main(thread: int, validation: bool, prediction: bool):
    logger.info("Using {} threads.".format(thread))
    if validation:
        logger.info("Starting validation...")
        validate_model("merged_click_data", thread)

    if prediction:
        logger.info("Starting prediction...")
        generate_submission("merged_click_data", thread)

    logger.info("Finished")


if __name__ == '__main__':
    main()
