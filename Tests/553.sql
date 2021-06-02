USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='251008' and NumberRegister=26 and ReportYear=2018

select * from vw_getIdFileNumber where id=@idFile

select distinct c.id,553, d.DS1,p.id
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,RTRIM(DiagnosisCode) AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase
								INNER JOIN dbo.vw_RegisterPatient p ON
				p.rf_idFiles=@idFile
				and r.id=p.rf_idRecordCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS1=(mkb.DiagnosisCode)
					AND p.rf_idV005=ISNULL(mkb.Sex,p.rf_idV005)
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null
--на соответствие диагноза из ОМС
select distinct c.id,553,d.DS1
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase
								left join vw_sprMKB10InOMS mkb on
					d.DS1=(mkb.DiagnosisCode)
					and c.DateEnd>=mkb.DateBeg
					and c.DateEnd<=mkb.DateEnd
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null

SELECT * 
FROM OMS_NSI.dbo.sprMKB 
WHERE DiagnosisCode='N44'

SELECT * FROM dbo.vw_RegisterPatient_test WHERE id=86165288
go
