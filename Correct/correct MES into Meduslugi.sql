use RegisterCases
go
declare @t as table(rf_idCase bigint,MES varchar(15))
insert @t
select c.id,mes.MES
from t_Case c inner join t_mes mes on
			c.id=mes.rf_idCase
		left join t_Meduslugi m on
		c.id=m.rf_idCase
where m.rf_idCase is null

insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
					MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
select distinct  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
	   vw_c.MU_P,cast(DATEDIFF(D,DateBegin,DateEnd) as decimal(6,2)),0.00,0.00,c.rf_idV004,c.rf_idDoctor
from t_Case c inner join @t i on
		c.id=i.rf_idCase
			  inner join t_Diagnosis d on
		c.id=d.rf_idCase
			  inner join (select MU,MU_P from vw_sprMUCompletedCase group by MU,MU_P) vw_c on
		i.MES=vw_c.MU	
where d.TypeDiagnosis=1  