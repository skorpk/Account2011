alter database RegisterCases set single_user with rollback immediate
go
use RegisterCases
go
begin transaction 
begin try
--выбираем задвоенные записи
declare @t as table(rf_idCase bigint,MES varchar(15))
insert @t
select mes.rf_idCase,mes.MES
from t_MES mes inner join t_Meduslugi m on
			mes.rf_idCase=m.rf_idCase
group by mes.rf_idCase,mes.MES
having COUNT(*)>1

--удаляем задвоенные записи
delete from t_Meduslugi where rf_idCase in (select rf_idCase from @t)

insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
					MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
select distinct  c.id,c.idRecordCase,c.GUID_Case,c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DS1,
	   vw_c.MU_P,cast(DATEDIFF(D,DateBegin,DateEnd) as decimal(6,2)),0.00,0.00,c.rf_idV004,c.rf_idDoctor
from t_Case c inner join @t i on
		c.id=i.rf_idCase
			  inner join vw_Diagnosis d on
		c.id=d.rf_idCase
			  inner join (select MU,MU_P from vw_sprMUCompletedCase group by MU,MU_P) vw_c on
		i.MES=vw_c.MU	
--where d.TypeDiagnosis=1 

end try
begin catch
	select ERROR_MESSAGE()
	if @@TRANCOUNT>0
	rollback transaction
goto Exit1--выходим из обработки данных
end catch
if @@TRANCOUNT>0
	commit transaction
--выход из пакета	
Exit1:
go
alter database RegisterCases set multi_user
go
use RegisterCases
go
select m.rf_idCase,COUNT(*) as col
from t_MES mes inner join t_Meduslugi m on
			mes.rf_idCase=m.rf_idCase
group by m.rf_idCase
having COUNT(*)>1
order by col desc 