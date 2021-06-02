USE RegisterCases
go
create VIEW vw_CaseNotExistInAccount
as
SELECT a.rf_idFiles,pb.ENP, a.ReportYear,c.rf_idMO AS CodeM, c.DateBegin,c.DateEnd, r.NewBorn, d.DiagnosisCode AS DS1, c.rf_idV006
from t_Case c INNER JOIN dbo.t_RecordCase r ON
					c.rf_idRecordCase=r.id
			  INNER JOIN dbo.t_RegistersCase a ON
				  	r.rf_idRegistersCase=a.id
			  INNER JOIN dbo.t_RecordCaseBack rb ON
					c.id=rb.rf_idCase				 
				 INNER JOIN dbo.t_PatientBack pb ON
					rb.id=pb.rf_idRecordCaseBack
				INNER JOIN dbo.t_CaseBack cb ON
					rb.id=cb.rf_idRecordCaseBack								
				INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1              
WHERE c.rf_idV006<3 AND c.DateEnd>'20170101' AND cb.TypePay=1 AND a.ReportYear>2016
	AND NOT EXISTS(SELECT * FROM AccountOMS.dbo.t_Case WHERE GUID_Case=c.GUID_Case AND DateEnd>'20170101')
GO
USE AccountOMS
go
DROP VIEW vw_CaseInAccountWithoutFin
go
CREATE VIEW vw_CaseInAccountWithoutFin
AS
SELECT f.CodeM,a.NumberRegister,ps.ENP,a.ReportYear, c.id,c.DateBegin,c.DateEnd, r.NewBorn, d.DiagnosisCode AS DS1, c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					 INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
WHERE f.DateRegistration>'20170101' AND c.DateEnd>'20161231' and d.TypeDiagnosis=1 AND c.rf_idV006 <3 
		AND NOT	EXISTS(SELECT 1
						FROM dbo.t_PaymentAcceptedCase2	f
						WHERE f.DateRegistration>='20170101' AND f.DateRegistration<=GETDATE() AND f.rf_idCase=c.id)
GO
DROP VIEW vw_CaseInAccountFin
go
CREATE VIEW dbo.vw_CaseInAccountFin
AS
SELECT f.DateRegistration,f.CodeM,a.NumberRegister,ps.ENP,a.ReportYear,c.id,(c.AmountPayment-pc.AmountDeduction) AS AmountPay
		,c.DateBegin,c.DateEnd, r.NewBorn, d.DiagnosisCode AS DS1, c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					 INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN (
								SELECT f.rf_idCase,SUM(AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2	f
								WHERE f.DateRegistration>='20170101' AND f.DateRegistration<=GETDATE()
								GROUP BY f.rf_idCase
								)  pc ON
			c.id=pc.rf_idCase                  
WHERE f.DateRegistration>'20170101' AND c.DateEnd>'20161231' and d.TypeDiagnosis=1 AND c.rf_idV006 <3 AND (c.AmountPayment-pc.AmountDeduction)>0
go
