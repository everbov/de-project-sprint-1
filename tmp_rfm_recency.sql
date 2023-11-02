-- заполнение временной таблицы analysis.tmp_rfm_recency
--delete FROM analysis.tmp_rfm_recency
with orders_data as (select u.id,
case -- если нет заказов, то записываем самую раннюю дату
    when max(order_ts) isnull then (select min(order_ts) from analysis.orders)
    else max(order_ts)
end as last_order_date
from analysis.orders o
inner join analysis.orderstatuses os
on o.status=os.id and os.key='Closed' and extract('year' from o.order_ts)>=2022
full join analysis.users u on o.user_id = u.id
group by u.id)
---------------------------------------------------------------------------------------------
insert into analysis.tmp_rfm_recency (
select id as user_id,
ntile(5) OVER (ORDER BY last_order_date ASC) AS recency
from orders_data)