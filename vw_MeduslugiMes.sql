use RegisterCases
go
if OBJECT_ID('vw_MeduslugiMes',N'V') is not null
	drop view vw_MeduslugiMes
go
create view vw_MeduslugiMes
as
select m.id,m.rf_idCase,m.MUCode,m.IsChildTariff,m.Quantity,m.Price from t_Meduslugi m
union all
select c.id,mes.rf_idCase,mes.MES as MUCode,c.IsChildTariff,mes.Quantity,mes.Tariff
from t_MES mes inner join t_Case c on
		mes.rf_idCase=c.id
go
create nonclustered index IX_Mes_Case_Quantity on dbo.t_Mes(rf_idCase)
INCLUDE(MES,Quantity) with drop_existing