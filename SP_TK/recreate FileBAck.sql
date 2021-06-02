use RegisterCases
go
declare @t as table(idFile int,idFileBack int)
insert @t 
select fb.rf_idFiles,fb.id
from t_FileBack fb 
where fb.DateCreate>'20120701' and UserName='VTFOMS\sysdba'

delete from t_FileBack where id in (select idFileBack from @t)

update t_RefCasePatientDefine 
set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
where rf_idFiles in (select idFile from @t) and i.rf_idIteration<>1

--exec usp_RunFillBackTablesAfterAllIteration
