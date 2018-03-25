-- Add data role (train/test) to click_data

-- レコード数が多い時はUPDATEを使うべきではないという学びを得た

alter table click_data ADD role char(8);
update click_data
   set role = (case when click_id is null then 'train' else 'test' end)
;
