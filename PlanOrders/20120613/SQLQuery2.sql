use RegisterCases
go
select c.*
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.CodeM='141016'
		and a.NumberRegister=55
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		and r.idRecord=398
			inner join t_Case c on
		r.id=c.rf_idRecordCase
		and c.idRecordCase=398
			inner join t_Meduslugi m on
		c.id=m.rf_idCase



declare @inserted as table(MES char(16),rf_idCase bigint,TypeMES tinyint, Quantity decimal(5,2),Tariff decimal(15,2))
insert @inserted
select m.*
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.CodeM='141016'
		and a.NumberRegister=55
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		and r.idRecord=398
			inner join t_Case c on
		r.id=c.rf_idRecordCase
		and c.idRecordCase=398
			inner join t_MES m on
		c.id=m.rf_idCase


select distinct  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
	   vw_c.MU_P,cast(DATEDIFF(D,DateBegin,DateEnd) as decimal(6,2)),0.00,0.00,c.rf_idV004,c.rf_idDoctor
from t_Case c inner join (select distinct * from @inserted) i on
		c.id=i.rf_idCase
			  inner join (select rf_idCase,DiagnosisCode from t_Diagnosis where TypeDiagnosis=1 group by rf_idCase,DiagnosisCode ) d on
		c.id=d.rf_idCase
			  inner join (select MU,MU_P, AgeGroupShortName from vw_sprMUCompletedCase) vw_c on
		i.MES=vw_c.MU	
where vw_c.AgeGroupShortName=(case when c.Age>17 then 'â' else 'ä' end)