USE RegisterCases
go
DECLARE @idFileBack INT=221971,
		@idFile INT=130940
select c.idRecordCase as IDCASE,upper(c.GUID_Case) as ID_C ,cd.TypePay as OPLATA,p.rf_idSMO
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack AND cd.TypePay=1 AND p.rf_idSMO='34007'
group by c.idRecordCase,c.GUID_Case,cd.TypePay,p.rf_idSMO


GO