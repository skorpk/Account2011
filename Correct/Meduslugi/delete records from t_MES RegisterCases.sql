alter database RegisterCases set single_user with rollback immediate
go
use RegisterCases
go
select distinct mes.* 
into tmp_mes 
from t_MES mes inner join t_Case c on
			mes.rf_idCase=c.id
			   inner join t_RecordCase rc on
			c.rf_idRecordCase=rc.id
			  inner join t_RegistersCase r on
			rc.rf_idRegistersCase=r.id and
			r.ReportYear=2012	
--удал€ем данные из таблицы ћЁ— за 2012 т.к. присутствуют двойные записи
delete from t_mes where rf_idCase in (select rf_idCase from tmp_mes)
go
--create unique nonclustered index QU_MES_Case on dbo.t_MES(rf_idCase) with IGNORE_DUP_KEY
--go
delete from t_Meduslugi where rf_idCase in (select rf_idCase from tmp_mes)
go
insert t_MES(rf_idCase,MES,Quantity,Tariff,TypeMES)
select rf_idCase,MES,Quantity,Tariff,TypeMES from tmp_mes
go
drop table tmp_mes
go
alter database RegisterCases set multi_user

select m.*
from t_Case c inner join t_Meduslugi m on
		c.id=m.rf_idCase 
		and c.rf_idMO='391003'
		 	inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
			inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
			inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth>0 and r.ReportMonth<=1 and
		r.ReportYear=2012				
			inner join t_MES mes on
		c.id=mes.rf_idCase	
where r.NumberRegister in (2) and unitCode=1
