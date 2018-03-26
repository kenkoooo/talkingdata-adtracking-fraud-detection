-- Tabulate by app, channel and role

create table tab_cnt_app_channel as
    select 
        is_test, app, channel, count(*) as cnt, 1 as flg
    from
        click_data
    group by
        is_test, app, channel
    order by 
        is_test, app, channel
    ;

