use RegisterCases
go
declare @id int,
		@idFileBack int
select @idFileBack=f.id,@id=f.rf_idFiles
from vw_getIdFileNumber v inner join t_FileBack f on
		v.id=f.rf_idFiles
where v.CodeM='106001' and ReportYear=2012 and NumberRegister=18 and f.UserName='VTFOMS\sysdba'

begin transaction
delete from t_FileBack where id=@idFileBack

update t_RefCasePatientDefine 
set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
where rf_idFiles=@id and i.rf_idIteration<>1

exec usp_FillBackTablesAfterAllIteration @id

select @idFileBack=f.id
from vw_getIdFileNumber v inner join t_FileBack f on
		v.id=f.rf_idFiles
where v.CodeM='106001' and ReportYear=2012 and NumberRegister=18 and f.UserName='VTFOMS\SKrainov'

exec usp_RegisterSP_TK @idFileBack

rollback
go
