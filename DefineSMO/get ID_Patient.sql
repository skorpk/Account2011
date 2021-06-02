use RegisterCases
go

SET STATISTICS PROFILE ON
GO
select v.Codem,p.Fam,p.Im,p.Ot,p.BirthDay,v.DateRegistration,v.NumberRegister,rb.rf_idCase
		--,e.ErrorNumber
		,c.DateBegin,c.DateEnd,i.rf_idIteration
	,d.DS1,mkb.Diagnosis,c.rf_idMO,c.rf_idDoctor
	,r.SeriaPolis,r.NumberPolis,c.AmountPayment--,c.rf_idV009
from t_RegisterPatient p inner join t_RefRegisterPatientRecordCase ref on
		p.id=ref.rf_idRegisterPatient
						inner join t_RecordCase r on
		ref.rf_idRecordCase=r.id
						inner join t_RecordCaseBack rb on
		r.id=rb.rf_idRecordCase	
						inner join vw_getIdFileNumber v on
		p.rf_idFiles=v.id
						inner join t_Case c on
		rb.rf_idCase=c.id
						INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
						inner join t_RefCasePatientDefine rd on
		c.id=rd.rf_idCase
						INNER JOIN dbo.vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
						inner join t_CasePatientDefineIteration i on
		rd.id=i.rf_idRefCaseIteration
		--				left join t_ErrorProcessControl e on					
		--rb.rf_idCase=e.rf_idCase
WHERE Fam='Крайнова' and Im='Марина' and BirthDay='19841012' AND c.DateEnd>'20160301' AND v.DateRegistration>'20160301'
ORDER BY v.DateRegistration desc
SET STATISTICS PROFILE OFF
GO