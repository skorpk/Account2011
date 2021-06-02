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

--�������� ������ �� �����
update p
set p.OKATO=t.OKATO
from t_PatientSMO p inner join #tOKATO t on
			p.ref_idRecordCase=t.rf_idRecordCase
			
--�������� ������ �� t_CaseDefineZP1Found � ��� ��� � ������ �� �����
update c
set c.OGRN_SMO=null, c.NPolcy=null
from #tOKATO cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration

--�������� ������ � ��� ��� ������ �� ���� ��� ������ � �������� �� � ��
update rf
set rf.IsUnloadIntoSP_TK=null
from #tOKATO cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase


drop table #tOKATO