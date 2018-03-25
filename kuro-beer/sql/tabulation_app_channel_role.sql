-- Tabulate by app, channel and role

create table tab_count_app_channel as
    select 
        role, app, channel, count(*) as cnt
    from
        click_data
    group by
        role, app, channel
    order by 
        role, app, channel
    ;

