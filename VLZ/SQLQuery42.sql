use RegisterCases
go
select p.rf_idSMO,p.OKATO,pay.TypePay,f.FileNameHRBack,e.ErrorNumber
from t_FileBack f inner join t_RegisterCaseBack a on
		f.id=a.rf_idFilesBack
		and CodeM='254504'
		and a.NumberRegister=10
		--and a.PropertyNumberRegister=2
		and a.ReportYear=2012
					inner join t_RecordCaseBack r on
		a.id=r.rf_idRegisterCaseBack
					inner join t_PatientBack p on
		r.id=p.rf_idRecordCaseBack
					inner join t_CaseBack pay on
		r.id=pay.rf_idRecordCaseBack
					left join t_ErrorProcessControl e on
		r.rf_idCase=e.rf_idCase
where p.rf_idSMO='00'