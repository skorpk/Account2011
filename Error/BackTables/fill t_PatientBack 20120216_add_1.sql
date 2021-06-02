use RegisterCases
go
--таблица в которой сохраняются записи у которых не определена СМО. 
--не определена она по причине того что в таблицу t_CaseDefineZP1Found не были добавлены записи по каким то причинам
begin transaction

--insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO) values(2591872,1,null,3408490004941612,'34001','18000')


declare @tCase as table(rf_idCase bigint,rf_idRecordCaseBack bigint,rf_idFiles int)
insert @tCase
select recb.rf_idCase,recb.id,fb.rf_idFiles
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							left join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where p.rf_idRecordCaseBack is null
group by  recb.rf_idCase,recb.id,fb.rf_idFiles

insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select t.rf_idRecordCaseBack,r.rf_idF008,r.SeriaPolis,r.NumberPolis,isnull(s.rf_idSMO,'00'),isnull(s.OKATO,'00000')
from @tCase t inner join t_Case c on
		t.rf_idCase=c.id
				inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
				left join t_PatientSMO s on
		r.id=s.ref_idRecordCase

update cb
set TypePay=2
from @tCase	t inner join t_CaseBack cb on
		t.rf_idRecordCaseBack=cb.rf_idRecordCaseBack

insert t_ErrorProcessControl(rf_idCase,ErrorNumber,rf_idFile)
select t.rf_idCase,57,t.rf_idFiles
from @tCase t

commit

--select *
--from PolicyRegister.dbo.ZP1
--where ID=542383

			