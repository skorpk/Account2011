use RegisterCases
go
declare @CaseDefined TVP_CasePatient,
		@CaseDefined2 TVP_CasePatient, --для иногородних
		@idFile int=2384

insert @CaseDefined(rf_idCase,ID_Patient)
select rb.rf_idCase,rp.id
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_RecordCaseBack rb on
			r.id=rb.rf_idRecordCase
						inner join t_PatientBack p on
			rb.id=p.rf_idRecordCaseBack
						inner join t_RegisterPatient rp on
			r.id=rp.rf_idRecordCase
where p.OKATO not in ('18000','00000') and a.rf_idFiles=@idFile

--заполняем таблицу для иногородних по тем у кого не определена страховая принадлежность, но есть ОКАТО не волгоградской области
insert @CaseDefined2(rf_idCase,ID_Patient)
select rf.rf_idCase,rf.rf_idRegisterPatient
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
			and c.OGRN_SMO is null	
								inner join t_Case c1 on
			rf.rf_idCase=c1.id											  
								inner join t_RecordCase r on
			c1.rf_idRecordCase=r.id
								inner join t_PatientSMO p on
			r.id=p.ref_idRecordCase
			and p.OKATO!='18000' 
			and p.OKATO is not null
where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)


select 57,@idFile,c1.id
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)						
						inner join t_Case c1 on
			cd.rf_idCase=c1.id
						inner join t_RecordCase rc on
			c1.rf_idRecordCase=rc.id
						inner join t_RegistersCase reg on
			rc.rf_idRegistersCase=reg.id
						left join @CaseDefined2 cd2 on
			cd.rf_idCase=cd.rf_idCase
			and cd.ID_Patient=cd2.ID_Patient					
where (c.OGRN_SMO is null) and (c.NPolcy is null) and (cd2.rf_idCase is null)
group by c1.id

--добавляем записи в t_PatientBack  для иногородних по тем у кого не определена страховая принадлежность, но есть ОКАТО не волгоградской области
select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,34,p.OKATO
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase	
						inner join t_Case c1 on
			cd.rf_idCase=c1.id
						inner join t_RecordCase rc on
			c1.rf_idRecordCase=rc.id										
						inner join t_PatientSMO p on
			rc.id=p.ref_idRecordCase
			and p.OKATO!='18000' 
			and p.OKATO is not null
where (OGRN_SMO is null) and (NPolcy is null)		