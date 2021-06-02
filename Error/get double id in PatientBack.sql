use RegisterCases
go
declare @tDoubleSMO as table(rf_idCase bigint,id int)
insert @tDoubleSMO
select r.rf_idCase,f.id
from t_FileBack f inner join t_RegisterCaseBack a on
		f.id=a.id
		and f.DateCreate>'20120210'
				inner join t_RecordCaseBack r on
		a.id=r.rf_idRegisterCaseBack
				inner join t_PatientBack p on
		r.id=p.rf_idRecordCaseBack				
group by r.rf_idCase,NumberRegister,f.id,f.DateCreate
having COUNT(*)>1

--select *
--from t_RegisterCaseBack where rf_idFilesBack=6276

--select *
--from t_RecordCaseBack r inner join t_CaseBack cb on
--				r.id=cb.rf_idRecordCaseBack
--						inner join t_PatientBack p on
--		r.id=p.rf_idRecordCaseBack				
--where r.rf_idCase=2549141

select distinct r.rf_idFiles
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration z on
				r.id=z.rf_idRefCaseIteration
								inner join @tDoubleSMO t on
				r.rf_idCase=t.rf_idCase	
							inner join t_CaseDefine cd on							
				r.id=cd.rf_idRefCaseIteration
							inner join t_CaseDefineZP1Found z1 on
				r.id=z1.rf_idRefCaseIteration
--order by r.id			

--select f.id,z.DateOperationt,i.rf_idIteration
--from t_RefCasePatientDefine f inner join t_CasePatientDefineIteration i on
--				f.id=i.rf_idRefCaseIteration
--								inner join t_CaseDefineZP1 z on
--				f.id=z.rf_idRefCaseIteration
--								inner join t_CaseDefineZP1Found zf on
--				z.rf_idRefCaseIteration=zf.rf_idRefCaseIteration
--				and z.rf_idZP1=zf.rf_idZP1					
--where rf_idFiles=3325 and i.rf_idIteration in(2,4)