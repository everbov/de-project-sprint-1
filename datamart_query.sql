insert into analysis.dm_rfm_segments
select 
trf.user_id,
trr.recency as recency,
trf.frequency as frequency,
trmv.monetary_value as monetary_value 
from analysis.tmp_rfm_frequency trf
inner join analysis.tmp_rfm_recency trr on trf.user_id=trr.user_id
inner join analysis.tmp_rfm_monetary_value trmv  on trf.user_id=trmv.user_id 

/* Дамп первых 10 записей
user_id, recency,frequency,monetary_value
0				1				3				3
1				4				3				3
2				2				3				3
3				2				3				3
4				4				3				3
5				5				5				5
6				1				3				3
7				4				2				2
8				1				2				2
9				1				2				2
*/