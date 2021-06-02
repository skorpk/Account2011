use RegisterCases
go
declare @id int
declare @idRecord as table(id bigint)

select @id=id
from dbo.vw_getIdFileNumber where CodeM='254505' and ReportYear=2012 and NumberRegister=22

--insert @idRecord
select r.id,i.rf_idIteration
from t_RefCasePatientDefine r left join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
where rf_idFiles=@id and i.rf_idIteration is null

begin transaction
	insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,DateDefine)
	select rf_idRefCaseIteration,rf_idZP1,GETDATE()
	from t_CaseDefineZP1 where rf_idRefCaseIteration in (select id from @idRecord)

	insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration) 
	select id,4 from @idRecord

	select *
	from t_CaseDefineZP1Found where rf_idRefCaseIteration in (select id from @idRecord)

	exec usp_FillBackTablesAfterAllIteration @id

rollback
