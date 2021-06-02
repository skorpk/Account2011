USE RegisterCases
go
SET NOCOUNT ON
declare @id int
select @id=id from vw_getIdFileNumber where CodeM='255601' and NumberRegister=12400 and ReportYear=2012
select * from vw_getFileBack where rf_idFiles=@id
select z1.* 
from t_RefCasePatientDefine r inner join t_CaseDefineZP1 z on
		r.id=z.rf_idRefCaseIteration
							inner join PolicyRegister.dbo.ZP1 z1 on
		z.rf_idZP1=z1.ID
where rf_idFiles=@id and r.IsUnloadIntoSP_TK is null

go