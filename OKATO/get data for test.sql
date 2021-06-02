use RegisterCases
go
select r.id as rf_idRecordCase,rb.rf_idCase,rp.id as rf_idPatient,p.OKATO
into #tOKATO
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_RecordCaseBack rb on
			r.id=rb.rf_idRecordCase
						inner join t_PatientBack p on
			rb.id=p.rf_idRecordCaseBack
						inner join t_RegisterPatient rp on
			r.id=rp.rf_idRecordCase
where p.OKATO not in ('18000','00000') and a.rf_idFiles=2384

--обновл€ю данные по ќ ј“ќ
update p
set p.OKATO=t.OKATO
from t_PatientSMO p inner join #tOKATO t on
			p.ref_idRecordCase=t.rf_idRecordCase
			
--обновл€ю данные по t_CaseDefineZP1Found о том что € ничего не нашел
update c
set c.OGRN_SMO=null, c.NPolcy=null
from #tOKATO cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration

--обновл€ю записи о том что случаи не были еще отданы в реестрах —ѕ и “ 
update rf
set rf.IsUnloadIntoSP_TK=null
from #tOKATO cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase


drop table #tOKATO