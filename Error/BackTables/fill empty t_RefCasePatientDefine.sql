use RegisterCases
--select * from vw_getIdFileNumber where CodeM='106001' and NumberRegister=2 and ReportYear=2012

--select *
--from t_FileBack where rf_idFiles=2125

declare @idFile int=2125
begin tran 
declare @t as table(rf_idRefCaseIteration int,rf_idCase bigint, rf_idRegisterPatient bigint)
--вставляем данные по таблицам итераций.
insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles,IsUnloadIntoSP_TK)
output inserted.id,inserted.rf_idCase,inserted.rf_idRegisterPatient into @t
select r.rf_idCase,p.id,f.rf_idFiles,1
from t_FileBack f inner join t_RegisterCaseBack a on
			f.id=a.rf_idFilesBack
			and f.rf_idFiles=@idFile
					inner join t_RecordCaseBack r on
			a.id=r.rf_idRegisterCaseBack
					inner join vw_RegisterPatient p on
			r.rf_idRecordCase=p.rf_idRecordCase
			
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)			
select t.rf_idRefCaseIteration,1 from @t t

insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined,SMO,SPolicy,NPolcy,RN,rf_idF008)
select c.id,'20120112',null,case when p.rf_idF008=3 then p.NumberPolis else null end,1,p.rf_idSMO,p.SeriaPolis,p.NumberPolis,null,p.rf_idF008
from @t t inner join t_RecordCaseBack c on
			t.rf_idCase=c.rf_idCase
		inner join t_PatientBack p on
			c.id=p.rf_idRecordCaseBack

			
insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles,IsUnloadIntoSP_TK)			
select c.id,p.id,a.rf_idFiles,null
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
						left join t_RecordCaseBack rb on
			c.id=rb.rf_idCase
where rb.id is null

select *
from t_RefCasePatientDefine r
where r.rf_idFiles=@idFile
						
--производим повторный запуск определения страховой принадлежности на ЦС ЕРЗ				
exec usp_DefineSMOIteration2_4Repeat @idFile

commit

