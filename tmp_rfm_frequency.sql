-- заполнение временной таблицы analysis.tmp_rfm_frequency
with orders_data as (select u.id,
count(o.status) as orders,
count(o.payment) as orders_value
from production.orders o
inner join production.orderstatuses os
on o.status=os.id and os.key='Closed' and extract('year' from o.order_ts)=2022
full join production.users u on o.user_id = u.id
group by u.id)
insert into analysis.tmp_rfm_frequency (
select id as user_id,
ntile(5) OVER (ORDER BY orders ASC) AS frequency
from orders_data)