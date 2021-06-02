alter database AccountOMS set single_user with rollback immediate
go
use AccountOMS
go
declare @t as table (rf_idCase bigint,MES varchar(16))
insert @t
select rf_idCase,MES from t_MES
group by rf_idCase,MES 

--удаляем данные
delete from t_Meduslugi where rf_idCase in (select rf_idCase from @t)

insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
					MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
select distinct  c.id,c.idRecordCase
		,NEWID()
		,c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd
		,d.DiagnosisCode
		, vw_c.MUGroupCodeP,vw_c.MUUnGroupCodeP,vw_c.MUCodeP,cast(DATEDIFF(D,DateBegin,DateEnd) as decimal(6,2)),0.00,0.00,c.rf_idV004,c.rf_idDoctor
from t_Case c inner join @t i on
		c.id=i.rf_idCase
			  inner join (select rf_idCase,DiagnosisCode from t_Diagnosis where TypeDiagnosis=1 group by rf_idCase,DiagnosisCode ) d on
		c.id=d.rf_idCase
			  inner join (select MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP from vw_sprMUCompletedCase group by MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP) vw_c on
		i.MES=vw_c.MU	
go
alter database AccountOMS set multi_user 
