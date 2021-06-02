USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='311001' and NumberRegister=112

select zl.*
from t_RefCasePatientDefine r inner join t_CaseDefineZP1 z on
		r.id=z.rf_idRefCaseIteration
		and r.rf_idFiles=@idFile
							inner join PolicyRegister.dbo.ZP1 zl on
		z.rf_idZP1=zl.ID
go