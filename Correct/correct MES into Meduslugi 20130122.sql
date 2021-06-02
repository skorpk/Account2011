USE RegisterCases
go
declare @inserted as table(rf_idCase bigint,MES varchar(15))
insert @inserted
select distinct c.id,mes
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.DateRegistration>='20130121'
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_MES mes on
		c.id=mes.rf_idCase
				INNER JOIN vw_sprMUCompletedCase m1 ON
		mes.MES=m1.MU
		and m1.MUGroupCode<>2 AND m1.MUUnGroupCode<>78
				left join (select m.* 
							from t_Meduslugi m inner join vw_sprMU m1 on
									m.MUCode=m1.MU) m on
		c.id=m.rf_idCase
where m.id is null

select @@ROWCOUNT

INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
							MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
			   vw_c.MU_P			   
			   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
					else (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))end) end
			   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
FROM t_Case c INNER JOIN @inserted i ON
		c.id=i.rf_idCase
			  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode ) d ON
		c.id=d.rf_idCase
			  INNER JOIN (SELECT MU,MU_P, AgeGroupShortName FROM vw_sprMUCompletedCase WHERE MUGroupCode<>2 AND MUUnGroupCode<>78) vw_c ON
		i.MES=vw_c.MU	
WHERE vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'â' ELSE 'ä' END)-- and c.id=15223252

go