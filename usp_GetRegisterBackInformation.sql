USE RegisterCases
go
if OBJECT_ID('usp_GetRegisterBackInformation',N'P') is not null
drop proc usp_GetRegisterBackInformation
go
create procedure usp_GetRegisterBackInformation
				@idFileBack int
as
select sum(case when p.rf_idSMO='34' then 1 else 0 end) as AnotherTown
	   ,sum(case when p.rf_idSMO!='00' and  p.rf_idSMO!='34' then 1 else 0 end) as VolgTown
	   ,sum(case when p.rf_idSMO='00' then 1 else 0 end) as ErrorDefinePatient
	   ,SUM(case when cp.TypePay=1 then 1 else 0 end) as CaseForPay
	   ,SUM(case when cp.TypePay=2 then 1 else 0 end) as CaseForNotPay
from t_RegisterCaseBack ab inner join t_RecordCaseBack rb on
			ab.id=rb.rf_idRegisterCaseBack
			and ab.rf_idFilesBack=@idFileBack
						inner join t_PatientBack p on
			rb.id=p.rf_idRecordCaseBack
						INNER JOIN dbo.t_CaseBack cp ON
				rb.id=cp.rf_idRecordCaseBack					
						
			