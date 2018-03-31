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


-- とりあえず時間変数だけ用意
with chtime as (
    select
        id,
        click_time + interval '8 hour' as click_time_ch
    from sample
)
select
    *, 
    ip*10^7 + os*10^4 + device as uq_user,
    date_trunc('day', click_time_ch) as click_date,
    extract(hour from click_time_ch) as click_hour,
    date_trunc('hour', click_time_ch) as click_time_hour,
    date_trunc('min', click_time_ch) as click_time_1min,
    date_trunc('hour',2*(click_time - date_trunc('hour', click_time) + interval '15 minutes'))/2 as click_time_30min,
    date_trunc('hour',4*(click_time - date_trunc('hour', click_time) + interval '7 minutes 30 seconds'))/2 as click_time_15min,
    date_trunc('hour',6*(click_time - date_trunc('hour', click_time) + interval '5 minutes'))/2 as click_time_10min,
    date_trunc('hour',12*(click_time - date_trunc('hour', click_time) + interval '2 minutes 30 seconds'))/2 as click_time_5min
from 
    sample T1 left join chtime T2 on T1.id = T2.id
;

















