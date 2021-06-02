use RegisterCases
go

select fb.rf_idFiles,fb.id,fb.CodeM,count(rc.id)
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							left join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where p.rf_idRecordCaseBack is null and fb.DateCreate>'20150528'
group by  fb.rf_idFiles,fb.id,fb.CodeM
/*
--נאספמנלטנמגûגאול נווסענ ÑÏ ט ÒÊ
begin transaction
delete from t_FileBack where id in (select id from @t)

update t_RefCasePatientDefine 
set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
where rf_idFiles in (select rf_idFiles from @t) and i.rf_idIteration<>1

select fb.rf_idFiles,fb.id,fb.CodeM,count(rc.id)
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							left join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where p.rf_idRecordCaseBack is null and fb.DateCreate>'20121010'
group by  fb.rf_idFiles,fb.id,fb.CodeM

commit
*/