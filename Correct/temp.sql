use RegisterCases
go
--select id,FileNameHR,DateRegistration,SUBSTRING(FileNameHR,4,6),CountSluch
--from t_File where FileNameHR like 'HRM395303%'
select id,FileNameHRBack,SUBSTRING(FileNameHRBack,8,6)
from t_FileBack 
----delete from t_FileBack where id=470
----delete from t_RefCasePatientDefine where rf_idFiles=264
----delete from t_File where id=264

--select * 
--from t_RefCasePatientDefine 
----from t_RefCasePatientDefine rf inner join t_CaseDefine cd on
----			rf.id=cd.rf_idRefCaseIteration
--where rf_idFiles=360 --and IsUnloadIntoSP_TK is null


--select * 
--from t_FileBack f inner join t_RegisterCaseBack r on
--			f.id=r.rf_idFilesBack
--where rf_idFiles in (264)
select c.id,c.GUID_Case,r.id,cb.TypePay,fb.id,fb.FileNameHRBack
from t_Case c inner join t_RecordCaseBack r on
		c.id=r.rf_idCase
			inner join t_CaseBack cb on
		r.id=cb.rf_idRecordCaseBack
			inner join t_RegisterCaseBack rc on
		r.rf_idRegisterCaseBack=rc.id
			inner join t_FileBack fb on
		rc.rf_idFilesBack=fb.id			
where GUID_Case='DBC65703-3CDB-6BCF-4ACC-27353CEA7824'
--go

select upper(c.GUID_Case) as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
where rf_idFilesBack=254 and c.id in (220850,221143)
group by c.GUID_Case,e.ErrorNumber
