USE RegisterCases
/*
create VIEW vw_CaseDispNotExistInAccount
as
SELECT a.rf_idFiles,pb.ENP,d.TypeDisp, a.ReportYear,c.rf_idMO AS CodeM
from t_Case c INNER JOIN dbo.t_RecordCase r ON
					c.rf_idRecordCase=r.id
			  INNER JOIN dbo.t_RegistersCase a ON
				  	r.rf_idRegistersCase=a.id
			  INNER JOIN dbo.t_RecordCaseBack rb ON
					c.id=rb.rf_idCase
				 INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase                    
				 INNER JOIN dbo.t_PatientBack pb ON
					rb.id=pb.rf_idRecordCaseBack
				INNER JOIN dbo.t_CaseBack cb ON
					rb.id=cb.rf_idRecordCaseBack								
WHERE d.TypeDisp IN('ÄÂ1','ÄÂ2','ÎÏÂ') AND c.DateEnd>'20170101' AND cb.TypePay=1 AND a.ReportYear>2016
	AND NOT EXISTS(SELECT * FROM AccountOMS.dbo.t_Case WHERE GUID_Case=c.GUID_Case AND DateEnd>'20170101')
go

*/
USE AccountOMS
go
alter VIEW vw_CaseDispInAccountWithoutFin
AS
SELECT f.CodeM,a.NumberRegister,ps.ENP,a.ReportYear,d.TypeDisp, c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					 INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase
WHERE f.DateRegistration>'20170101' AND c.DateEnd>'20161231' and d.TypeDisp IN('ÄÂ1','ÄÂ2','ÎÏÂ') 
		AND NOT	EXISTS(SELECT 1
						FROM dbo.t_PaymentAcceptedCase	f
						WHERE f.DateRegistration>='20170101' AND f.DateRegistration<=GETDATE() AND f.rf_idCase=c.id)
go
alter VIEW vw_CaseDispInAccountFin
AS
SELECT f.CodeM,a.NumberRegister,ps.ENP,a.ReportYear,d.TypeDisp, c.id,(c.AmountPayment-pc.AmountDeduction) AS AmountPay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					 INNER JOIN dbo.t_DispInfo d ON
			c.id=d.rf_idCase
					INNER JOIN (
								SELECT f.rf_idCase,SUM(AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase	f
								WHERE f.DateRegistration>='20170101' AND f.DateRegistration<=GETDATE()
								GROUP BY f.rf_idCase
								)  pc ON
			c.id=pc.rf_idCase                  
WHERE f.DateRegistration>'20170101' AND c.DateEnd>'20161231' and d.TypeDisp IN('ÄÂ1','ÄÂ2','ÎÏÂ') AND (c.AmountPayment-pc.AmountDeduction)>0
go
												
