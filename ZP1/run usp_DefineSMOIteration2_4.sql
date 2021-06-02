use RegisterCases
go
declare @id int

select @id=id
from dbo.vw_getIdFileNumber where CodeM='251002' and ReportYear=2013 and NumberRegister=13500

select r.id,i.rf_idIteration
from t_RefCasePatientDefine r left join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
where rf_idFiles=@id and i.rf_idIteration is null

begin transaction
	exec usp_DefineSMOIteration2_4Repeat @id
commit