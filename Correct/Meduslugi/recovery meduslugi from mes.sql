alter database AccountOMS set single_user with rollback immediate
go
use AccountOMS
go
select distinct *
into tmp_meduslugi
from t_Meduslugi  

truncate table t_Meduslugi

insert t_Meduslugi
select *
from tmp_meduslugi
go
drop table tmp_meduslugi
go
alter database AccountOMS set multi_user 
go
select rf_idCase,GUID_MU
from t_Meduslugi
group by rf_idCase,GUID_MU
having COUNT(*)>1
