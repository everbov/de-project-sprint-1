--DROP VIEW analysis.orders;
CREATE VIEW analysis.orders AS 
with OSL1 as (select order_id,  max(dttm) as dttm  from production.OrderStatusLog group by order_id), 
order_states as (select OSL1.order_id,osl2.status_id  from OSL1 inner join production.OrderStatusLog OSL2 on OSL1.dttm =osl2.dttm) 
SELECT po.order_id, po.order_ts, po.user_id, po.bonus_payment, po.payment, po."cost", po.bonus_grant, os.status_id as status
FROM production.orders po
left join order_states os on po.order_id =os.order_id
