# talkingdata-adtracking-fraud-detection

[Competition Home](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection)
[Kernels](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/kernels)
[Discussion](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/discussion)

## Data Description

For this competition, your objective is to predict whether a user will download an app after clicking a mobile app advertisement.

### Data fields

Each row of the training data contains a click record, with the following features.

- ip: ip address of click.
- app: app id for marketing.
- device: device type id of user mobile phone (e.g., iphone 6 plus, iphone 7, huawei mate 7, etc.)
- os: os version id of user mobile phone
- channel: channel id of mobile ad publisher
- click_time: timestamp of click (UTC)
- attributed_time: if user download the app for after clicking an ad, this is the time of the app download
- is_attributed: the target that is to be predicted, indicating the app was downloaded

Note that ip, app, device, os, and channel are encoded.

The test data is similar, with the following differences:

- click_id: reference for making predictions
- is_attributed: not included

