use RegisterCases
go
--update t_File
--set FileNameHR=RTRIM(FileNameHR)
--go
--update t_FileBack
--set FileNameHRBack=RTRIM(FileNameHRBack)
select f.*
from t_File f left join t_FileBack fb on
		f.id=fb.rf_idFiles
where fb.id is null

--delete from t_File where id in (70)

select * 
from t_RefCasePatientDefine r inner join t_CaseDefine c on
		r.id=c.rf_idRefCaseIteration
		and rf_idFiles=70
		
select * 
from t_RefCasePatientDefine r inner join t_CaseDefineZP1 c on
		r.id=c.rf_idRefCaseIteration
		and rf_idFiles=70
		