create table analysis.dm_rfm_segments (
user_id int4 not null primary key, -- идентификатор пользователя
recency smallint check(recency >= 1 AND recency <= 5), -- давность покупок
frequency smallint  check(frequency >= 1 AND frequency <= 5), -- частота покупок
monetary_value smallint  check(monetary_value >= 1 AND monetary_value <= 5) -- выручка
);