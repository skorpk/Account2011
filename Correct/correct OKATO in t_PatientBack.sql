use RegisterCases
go

declare @t as table(id int,idFile int)

insert @t
select fb.id, fb.rf_idFiles
from t_FileBack fb inner join t_RegisterCaseBack rb on
			fb.id=rb.rf_idFilesBack
					inner join t_RecordCaseBack rcb on
			rb.id=rcb.rf_idRegisterCaseBack
					inner join t_PatientBack pb on
			rcb.id=pb.rf_idRecordCaseBack
where OKATO='00000' and pb.rf_idSMO='34'
group by fb.id,fb.rf_idFiles

update t_RefCasePatientDefine  set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine rc inner join t_CasePatientDefineIteration i on
			rc.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,3,4)
					inner join (select t.idFile from @t t group by t.idFile) t on
			rc.rf_idFiles=t.idFile
where rc.IsUnloadIntoSP_TK=1

delete from t_FileBack where id in (select id from @t)
go

exec usp_RunFillBackTablesAfterAllIteration
go
