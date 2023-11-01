# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

{См. задание на платформе}
-----------

Цель проекта: собрать витрину для RFM-сегментации пользователей 


Имя витрины: analysis.dm_rfm_segments

Источник данных: production.tables

Поля витрины: int4
1. user_id - smallint - идентификатор пользователя
2. recency smallint - группа пользователя по давности покупки (от 1 до 5)
3. frequency smallint - группа пользователя по частоте покупок (от 1 до 5)
4. monetary_value smallint - группа пользователя по выручке от покупок (от 1 до 5)

Период данных: начиная с 2021 года

Периодичность обновления данных: не требуется

Учитываются только успешные заказы (CLOSED)


## 1.2. Изучите структуру исходных данных.

{См. задание на платформе}

-----------

{Впишите сюда ваш ответ}


## 1.3. Проанализируйте качество данных

{См. задание на платформе}
-----------
Прямых требований к качеству данных нет в ТЗ.
Отдельно можно отметить, что:

- для избежания возможных ошибок используются различные типы стобцов в таблицах,
- для значимых полей таблиц установлено ограничение NOT NULL,
- присутствует зависимость FOREIGN KEY между таблицами,
- для значимых полей таблиц добавлены индексы, 
- добавлены первичные ключи для избежания дублирования записей


## 1.4. Подготовьте витрину данных

{См. задание на платформе}
Подготовка представлений  в схеме analysis для таблиц из схемы production:

CREATE VIEW analysis.users AS SELECT * FROM production.users;
CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;


### 1.4.1. Сделайте VIEW для таблиц из базы production.**

{См. задание на платформе}
```SQL
--Впишите сюда ваш ответ


```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

{См. задание на платформе}
```SQL
--Впишите сюда ваш ответ


```

### 1.4.3. Напишите SQL запрос для заполнения витрины

{См. задание на платформе}
```SQL
--Впишите сюда ваш ответ


```


