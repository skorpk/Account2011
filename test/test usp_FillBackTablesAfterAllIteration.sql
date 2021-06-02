use RegisterCases
go
declare @idFile int
declare @idFileBack int

select @idFileBack=MAX(fb.id),@idFile=fb.rf_idFiles
from vw_getIdFileNumber v inner join t_FileBack fb on
		v.id=fb.rf_idFiles
where v.CodeM='471001' and ReportYear=2012 and NumberRegister=12190
group by fb.rf_idFiles


--delete from t_FileBack where id=@idFileBack

--update t_RefCasePatientDefine 
--set IsUnloadIntoSP_TK=null
--from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
--		r.id=i.rf_idRefCaseIteration
--where rf_idFiles=@idFile and i.rf_idIteration<>1

--exec usp_FillBackTablesAfterAllIteration @idFile
--go


select *
from t_PatientSMO p inner join (
									select /*fb.id,fb.rf_idFiles,fb.CodeM,ab.NumberRegister,*/
											rb.rf_idRecordCase,rb.id,rb.rf_idCase
									from t_FileBack fb inner join t_RegisterCaseBack ab on
											fb.id=ab.rf_idFilesBack
											and fb.id=@idFileBack
														inner join t_RecordCaseBack rb on
											ab.id=rb.rf_idRegisterCaseBack
														left join t_PatientBack pt on
											rb.id=pt.rf_idRecordCaseBack
									where pt.rf_idRecordCaseBack is null
								) p1 on
				p.ref_idRecordCase=p1.rf_idRecordCase
				and p.OKATO!='18000'
select distinct rf.id
from (select rb.rf_idRecordCase,rb.id,rb.rf_idCase
	  from t_FileBack fb inner join t_RegisterCaseBack ab on
					fb.id=ab.rf_idFilesBack
					and fb.id=@idFileBack
							inner join t_RecordCaseBack rb on
					ab.id=rb.rf_idRegisterCaseBack
							left join t_PatientBack pt on
					rb.id=pt.rf_idRecordCaseBack
	  where pt.rf_idRecordCaseBack is null
		) cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
			  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			  inner join t_CaseDefineZP1 c on
			rf.id=c.rf_idRefCaseIteration
			
			