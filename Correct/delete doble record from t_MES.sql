--drop table tmp_mes
alter database AccountOMS set single_user with rollback immediate
go
use AccountOMS
go
select * into tmp_mes from t_MES
go
truncate table t_mes
go
create unique nonclustered index QU_MES_Case on dbo.t_MES(rf_idCase) with IGNORE_DUP_KEY
go
insert t_MES(rf_idCase,MES,Quantity,Tariff,TypeMES)
select rf_idCase,MES,Quantity,Tariff,TypeMES from tmp_mes
go
alter database AccountOMS set multi_user