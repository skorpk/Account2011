use RegisterCases
go
--таблица в которой сохраняются записи у которых не определена СМО. 
--не определена она по причине того что в таблицу t_CaseDefineZP1Found не были добавлены записи по каким то причинам
begin transaction

declare @tCase as table(rf_idCase bigint,rf_idRecordCaseBack bigint)
insert @tCase
select recb.rf_idCase,recb.id
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							left join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where p.rf_idRecordCaseBack is null
group by recb.rf_idCase,recb.id

insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select t.rf_idRecordCaseBack,r.rf_idF008,r.SeriaPolis,r.NumberPolis,s.rf_idSMO,case when s.rf_idSMO!='34' then '18000' else s.OKATO end
from @tCase t inner join t_Case c on
		t.rf_idCase=c.id
				inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
				inner join t_PatientSMO s on
		r.id=s.ref_idRecordCase

commit

--select *
--from PolicyRegister.dbo.ZP1
--where ID=542383

			