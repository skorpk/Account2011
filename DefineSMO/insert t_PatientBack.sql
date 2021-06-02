use RegisterCases
go
declare @id int,
		@idFileBack int
select @idFileBack=f.id,@id=f.rf_idFiles
from vw_getIdFileNumber v inner join t_FileBack f on
		v.id=f.rf_idFiles
where v.CodeM='165531' and ReportYear=2012 and NumberRegister=706 and f.UserName='VTFOMS\SKrainov'

declare @t as table(id int, idRecordBack int)

insert @t
select t.id,t.idRecordBack
from (
		select distinct rc.idRecord as N_ZAP,rc.id,recb.id as idRecordBack
		from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
					rcb.id=recb.rf_idRegisterCaseBack
									inner join t_RecordCase rc on
					recb.rf_idRecordCase=rc.id
		where rf_idFilesBack=@idFileBack
	 ) t left join (
					select distinct rc.idRecord as N_ZAP
					from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
								rcb.id=recb.rf_idRegisterCaseBack
												inner join t_RecordCase rc on
								recb.rf_idRecordCase=rc.id
												inner join t_PatientBack p on
								recb.id=p.rf_idRecordCaseBack
					where rf_idFilesBack=@idFileBack
					) t2 on t.N_ZAP=t2.N_ZAP
where t2.N_ZAP is null

begin transaction
--insert t_PatientSMO(ref_idRecordCase,OKATO,rf_idSMO,Name)
--values(3195324,'40000','34','Œ¿Œ "√—Ã "'),(3195288,'20000','34','¬Œ–ŒÕ≈∆— »… ‘»À»¿À Œ¿Œ "—“–¿’Œ¬¿ﬂ  ŒÃœ¿Õ»ﬂ "—Œ√¿«-Ã≈ƒ"')

insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,rf_idSMO,SeriaPolis,NumberPolis,OKATO)
select t.idRecordBack,r.rf_idF008,isnull(case when s.OKATO!='18000' then '34' else s.rf_idSMO end,'00000'),r.SeriaPolis,r.NumberPolis,isnull(s.OKATO,'00')
from t_RecordCase r inner join @t t on
		r.id=t.id
					inner join t_PatientSMO s on
				r.id=s.ref_idRecordCase

--exec usp_RegisterSP_TK @idFileBack

commit


