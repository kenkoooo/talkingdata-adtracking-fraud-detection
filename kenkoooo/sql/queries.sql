CREATE TABLE count_by_app_channel AS select app, channel, count((app, channel)) from click_data group by (app, channel);
