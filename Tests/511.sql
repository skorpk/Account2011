USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='106001' and NumberRegister=26 and ReportYear=2020
---В качестве
select c.id,c.Age, p.*, w.*
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN t_RefRegisterPatientRecordCase r1 ON
			r.id=r1.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
			r1.rf_idRegisterPatient=p.id
						INNER JOIN dbo.t_BirthWeight w ON
			c.id=w.rf_idCase
where c.Age<26

SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=121897442