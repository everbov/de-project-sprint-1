-- заполнение временной таблицы analysis.tmp_rfm_monetary_value
--delete FROM analysis.tmp_rfm_monetary_value
with orders_data as (select u.id,
sum(o.payment) as orders_value
from analysis.orders o
inner join analysis.orderstatuses os
on o.status=os.id and os.key='Closed' and extract('year' from o.order_ts)>=2022
full join analysis.users u on o.user_id = u.id
group by u.id)
insert into analysis.tmp_rfm_monetary_value (
select id as user_id,
ntile(5) OVER (ORDER BY orders_value ASC) AS monetary
from orders_data)