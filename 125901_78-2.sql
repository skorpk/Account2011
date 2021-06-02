use RegisterCases
go
declare @idFile int
select @idFile=rf_idFiles from vw_getFileBack where CodeM='125901' and NumberRegister=78 and PropertyNumberRegister=2

select r.ID_Patient,i.rf_idIteration,zp.rf_idZP1
from t_ErrorProcessControl e inner join t_Case c on
		e.rf_idCase=c.id
						inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
						inner join t_RefCasePatientDefine dt on
		c.id=dt.rf_idCase
						inner join t_CasePatientDefineIteration i on
		dt.id=i.rf_idRefCaseIteration
						inner join t_CaseDefineZP1Found zp on
		dt.id=zp.rf_idRefCaseIteration
where rf_idFile=@idFile


select * from PolicyRegister.dbo.ZP1 where ID in (1772465,1772466)