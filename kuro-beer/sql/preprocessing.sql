-- 用意したい変数一覧
-- * unique user id = ip*10^7 + os*10^4 + device (osは最大3桁, deviceは最大4桁)
-- * 現地時刻（UTC+8h） [以下すべて現地時刻ベース]
-- * date
-- * hour
-- * date-hour
-- * datetime(30min単位でrounding)
-- * datetime(15min単位でrounding)
-- * datetime(10min単位でrounding)
-- * datetime(5min単位でrounding)
-- * datetime(1min単位でrounding)
-- * uq userについて，直前のClickのapp, channel, 時間差
-- * uq userについて，直後のClickのapp, channel, 時間差
-- * uq userについて，直前n分間ののClick回数
-- * uq userについて，直後n分間のClick回数

-- 直前・直後のclickを取得
create temporary table tmp1 as
    select
        *,
        click_time + interval '8 hour' as click_time_ch,
        ip*10^7 + os*10^4 + device as uq_user,
        Row_Number() over(partition by ip, os, device, is_test order by click_time) as row_number,
        Row_Number() over(partition by ip, os, device, is_test order by click_time) + 1 as row_pre,
        Row_Number() over(partition by ip, os, device, is_test order by click_time) - 1 as row_post
    from sample
    ;

create temporary table tmp2 as
    select
        T1.id,
        T1.click_id,
        T1.ip,
        T1.app,
        T1.device,
        T1.os,
        T1.channel,
        T1.is_attributed,
        T1.is_test,
        T1.click_time_ch,
        T1.uq_user,
        T1.row_number,
        T1.click_time_ch - T2.click_time_ch as interval_pre,
        T2.app as app_pre,
        T2.channel as chan_pre
    from
        tmp1 T1 left join tmp1 T2 
            on T1.uq_user = T2.uq_user 
                and T1.is_test = T2.is_test 
                and T1.row_number = T2.row_pre
    where T1.click_time_ch >= timestamp '2017-11-07 00:00:00'
    ;

create temporary table tmp3 as
    select
        T1.id,
        T1.click_id,
        T1.ip,
        T1.app,
        T1.device,
        T1.os,
        T1.channel,
        T1.is_attributed,
        T1.is_test,
        T1.click_time_ch,
        T1.uq_user,
        T1.row_number,
        T1.app_pre,
        T1.chan_pre,
        T1.interval_pre,
        T2.click_time_ch - T1.click_time_ch as interval_post,
        T2.app as app_post,
        T2.channel as chan_post
    from
        tmp2 T1 left join tmp1 T2 
            on T1.uq_user = T2.uq_user 
                and T1.is_test = T2.is_test 
                and T1.row_number = T2.row_post
    ;

create temporary table tmp4 as
    select
        *,
        date_trunc('day', click_time_ch) as click_date,
        extract(hour from click_time_ch) as click_hour,
        date_trunc('hour', click_time_ch) as click_time_hour,
        date_trunc('min', click_time_ch) as click_time_1min,
        date_trunc('hour', click_time_ch) + date_trunc('hour', 2*(click_time_ch - date_trunc('hour', click_time_ch) + interval '15 minutes'))/2 as click_time_30min,
        date_trunc('hour', click_time_ch) + date_trunc('hour', 4*(click_time_ch - date_trunc('hour', click_time_ch) + interval '7 minutes 30 seconds'))/4 as click_time_15min,
        date_trunc('hour', click_time_ch) + date_trunc('hour', 6*(click_time_ch - date_trunc('hour', click_time_ch) + interval '5 minutes'))/6 as click_time_10min,
        date_trunc('hour', click_time_ch) + date_trunc('hour', 12*(click_time_ch - date_trunc('hour', click_time_ch) + interval '2 minutes 30 seconds'))/12 as click_time_5min
    from 
        tmp3
;

drop table tmp1, tmp2, tmp3;

/* create table click_data_mod as
    select
        *,
        count(*) over(partition by uq_user, click_doy) as cnt_doy,
        count(*) over(partition by uq_user, click_time_hour) as cnt_1hour,
        count(*) over(partition by uq_user, click_time_30min) as cnt_30min,
        count(*) over(partition by uq_user, click_time_15min) as cnt_15min,
        count(*) over(partition by uq_user, click_time_10min) as cnt_10min,
        count(*) over(partition by uq_user, click_time_5min) as cnt_5min,
        count(*) over(partition by uq_user, click_time_1min) as cnt_1min
    from 
        tmp4
;
 */
 
create table click_data_train_0403 as
    select
        id,
        click_id,
        ip,
        app,
        device,
        os,
        channel,
        is_attributed,
        is_test,
        click_time_ch,
        uq_user,
        app_pre,
        app_post,
        (case when app = app_pre  then 1 else 0 end) as same_app_pre,
        (case when app = app_post then 1 else 0 end) as same_app_post,
        chan_pre,
        chan_post,
        (case when channel = chan_pre then 1 else 0 end) as same_ch_pre,
        (case when channel = chan_post then 1 else 0 end) as same_ch_post,
        interval_pre,
        interval_post,
        click_hour,
        count(*) over(partition by uq_user, click_date) as cnt_day,
        count(*) over(partition by uq_user, click_time_hour) as cnt_1hour,
        count(*) over(partition by uq_user, click_time_30min) as cnt_30min,
        count(*) over(partition by uq_user, click_time_15min) as cnt_15min,
        count(*) over(partition by uq_user, click_time_10min) as cnt_10min,
        count(*) over(partition by uq_user, click_time_5min) as cnt_5min,
        count(*) over(partition by uq_user, click_time_1min) as cnt_1min
    from tmp4
    where is_test = 0
;

drop table tmp4;

create table tmp5 as
    select
        id,
        click_id,
        ip,
        app,
        device,
        os,
        channel,
        is_attributed,
        is_test,
        click_time_ch,
        uq_user,
        app_pre,
        app_post,
        (case when app = app_pre  then 1 else 0 end) as same_app_pre,
        (case when app = app_post then 1 else 0 end) as same_app_post,
        chan_pre,
        chan_post,
        (case when channel = chan_pre then 1 else 0 end) as same_ch_pre,
        (case when channel = chan_post then 1 else 0 end) as same_ch_post,
        interval_pre,
        interval_post,
        click_hour,
        count(*) over(partition by uq_user, click_date) as cnt_day,
        count(*) over(partition by uq_user, click_time_hour) as cnt_1hour,
        count(*) over(partition by uq_user, click_time_30min) as cnt_30min,
        count(*) over(partition by uq_user, click_time_15min) as cnt_15min,
        count(*) over(partition by uq_user, click_time_10min) as cnt_10min,
        count(*) over(partition by uq_user, click_time_5min) as cnt_5min,
        count(*) over(partition by uq_user, click_time_1min) as cnt_1min
    from tmp4
    where is_test = 1
;












