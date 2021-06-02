use RegisterCases
go
select p.Fam,p.Im,p.Ot,p.BirthDay,d.SeriaDocument,d.NumberDocument,c.rf_idMO,l.NameS,mkb10.Diagnosis,c.DateEnd
		,peop.CITY,peop.UL,peop.DOM,peop.KV
from t_RegisterPatient p inner join t_RegisterPatientDocument d on
		p.id=d.rf_idRegisterPatient
					inner join t_RefRegisterPatientRecordCase rf on
		p.id=rf.rf_idRegisterPatient
					inner join t_RecordCase r on
		rf.rf_idRecordCase=r.id
					inner join t_Case c on
		r.id=c.rf_idRecordCase
					inner join t_Diagnosis dia on
		c.id=dia.rf_idCase
		and dia.TypeDiagnosis=1
					inner join vw_sprT001 l on
		c.rf_idMO=l.CodeM
					inner join oms_nsi.dbo.sprMKB mkb10 on
		dia.DiagnosisCode=mkb10.DiagnosisCode
					inner join t_RefCasePatientDefine f on
		c.id=f.rf_idCase
					inner join t_CaseDefine cd on
		f.id=cd.rf_idRefCaseIteration
					inner join PolicyRegister.dbo.PEOPLE peop on
		cd.PID=peop.ID
where p.Fam='Москаленко' and p.Im='Марина' and p.Ot='Викторовна'