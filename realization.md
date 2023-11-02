# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

-----------

Цель проекта: собрать витрину для RFM-сегментации пользователей 


Имя витрины: analysis.dm_rfm_segments

Источник данных: production.tables

Поля витрины: 
1. user_id - int4 - идентификатор пользователя
2. recency smallint - группа пользователя по давности покупки (от 1 до 5)
3. frequency smallint - группа пользователя по частоте покупок (от 1 до 5)
4. monetary_value smallint - группа пользователя по выручке от покупок (от 1 до 5)

Период данных: начиная с 2022 года

Периодичность обновления данных: не требуется

Учитываются только успешные заказы (CLOSED)


## 1.2. Изучите структуру исходных данных.


-----------
1. recency - max(order_ts), при отсутствии заказов у пользователя ставить минимальную
2. frequency - count(order_id)
3. monetary_value - sum(cost)


## 1.3. Проанализируйте качество данных

-----------

- для избежания возможных ошибок используются различные типы стобцов в таблицах,
- для значимых полей таблиц установлено ограничение NOT NULL,
- присутствует зависимость FOREIGN KEY между таблицами,
- для значимых полей таблиц добавлены индексы, 
- добавлены первичные ключи для избежания дублирования записей


## 1.4. Подготовьте витрину данных





### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Подготовка представлений  в схеме analysis для таблиц из схемы production:
```SQL
CREATE VIEW analysis.users AS SELECT * FROM production.users;
CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;


```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

```SQL
create table analysis.dm_rfm_segments (
user_id int4 not null primary key, -- идентификатор пользователя
recency smallint check(recency >= 1 AND recency <= 5), -- давность покупок
frequency smallint  check(frequency >= 1 AND frequency <= 5), -- частота покупок
monetary_value smallint  check(monetary_value >= 1 AND monetary_value <= 5) -- выручка
);

```

### 1.4.3. Напишите SQL запрос для заполнения витрины

{Создание вспомогательных таблиц}

```SQL
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

```

{Наполнение вспомогательных таблиц}

recency:
```SQL
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
```

frequency
```SQL
--delete FROM analysis.tmp_rfm_frequency
with orders_data as (select u.id,
count(o.status) as orders,
count(o.payment) as orders_value
from analysis.orders o
inner join analysis.orderstatuses os
on o.status=os.id and os.key='Closed' and extract('year' from o.order_ts)>=2022
full join analysis.users u on o.user_id = u.id
group by u.id)
insert into analysis.tmp_rfm_frequency (
select id as user_id,
ntile(5) OVER (ORDER BY orders ASC) AS frequency
from orders_data)
```

monetary:
```SQL
--delete FROM analysis.tmp_rfm_monetary_value
with orders_data as (select u.id,
count(o.payment) as orders_value
from analysis.orders o
inner join analysis.orderstatuses os
on o.status=os.id and os.key='Closed' and extract('year' from o.order_ts)>=2022
full join analysis.users u on o.user_id = u.id
group by u.id)
insert into analysis.tmp_rfm_monetary_value (
select id as user_id,
ntile(5) OVER (ORDER BY orders_value ASC) AS monetary
from orders_data)

```


{Заполнение витрины}

```SQL
--delete FROM analysis.dm_rfm_segments
insert into analysis.dm_rfm_segments
select 
trf.user_id,
trr.recency as recency,
trf.frequency as frequency,
trmv.monetary_value as monetary_value 
from analysis.tmp_rfm_frequency trf
inner join analysis.tmp_rfm_recency trr on trf.user_id=trr.user_id
inner join analysis.tmp_rfm_monetary_value trmv  on trf.user_id=trmv.user_id 
```





{Доработка представления analysis.orders}

```SQL

--DROP VIEW analysis.orders;
CREATE VIEW analysis.orders AS 
with OSL1 as (select order_id,  max(dttm) as dttm  from production.OrderStatusLog group by order_id), 
order_states as (select OSL1.order_id,osl2.status_id  from OSL1 inner join production.OrderStatusLog OSL2 on OSL1.dttm =osl2.dttm) 
SELECT po.order_id, po.order_ts, po.user_id, po.bonus_payment, po.payment, po."cost", po.bonus_grant, os.status_id as status
FROM production.orders po
left join order_states os on po.order_id =os.order_id
```
