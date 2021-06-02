USE AccountOMS
GO
select * FROM AccountOMS.dbo.vw_CaseDispInAccountWithoutFin WHERE ENP='3487989724000039' AND ReportYear=2020

SELECT * FROM AccountOMS.dbo.vw_CaseDispInAccountFin WHERE ENP='3487989724000039' AND ReportYear=2020

select * 
FROM (SELECT f.DateRegistration,f.CodeM,a.NumberRegister,ps.ENP,a.ReportYear,v.TypeDisp, c.id--,(c.AmountPayment-pc.AmountDeduction) AS AmountPay
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
							INNER JOIN (VALUES('ÄÂ2','ÄÂ2'),('ÄÂ1','ÄÂ'),('ÄÂ4','ÄÂ'),('ÎÏÂ','ÄÂ'),('ÄÑ1','ÄC'),('ÄÓ1','ÄC'),('ÄÑ2','ÄC'),('ÄÓ2','ÄC'),('ÎÍ1','ÎÍ'),('ÎÍ2','ÎÍ')) v(id,TypeDisp) ON
					d.TypeDisp=v.id
							INNER JOIN (
										SELECT f.rf_idCase,SUM(AmountDeduction) AS AmountDeduction
										FROM dbo.t_PaymentAcceptedCase2	f
										WHERE f.DateRegistration>='20200101' AND f.DateRegistration<=GETDATE()
										GROUP BY f.rf_idCase
										)  pc ON
					c.id=pc.rf_idCase                  
		WHERE f.DateRegistration>'20200101' AND c.DateEnd>'20191231' AND (c.AmountPayment-pc.AmountDeduction)>0
) t
WHERE ENP='3487989724000039' AND ReportYear=2020

SELECT a.Account,c.DateEnd,d.TypeDisp
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
WHERE ENP='3487989724000039' AND ReportYear=2020