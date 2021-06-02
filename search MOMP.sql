USE AccountOMS
GO
;WITH cte
AS(
select f.CodeM,a.Account,c.idRecordCase,c.rf_idSubMO AS LPU_1,c.rf_idDepartmentMO AS PODR,a.ReportMonth,c.AmountPayment-SUM(p.AmountDeduction) AS AmountPay
from t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth>7
		AND a.ReportYear=2019
			  inner join dbo.t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			  inner join t_Case c on
		r.id=c.rf_idRecordCasePatient				
		AND c.DateEnd>='20190801'
			INNER JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.id=p.rf_idCase          
where f.CodeM='103001' AND c.rf_idV006<3 AND c.rf_idDepartmentMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM RegisterCases.dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM 
																			AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(v.PODR,0)
																			AND ISNULL(c.rf_idSubMO,'bla-bla')=ISNULL(v.LPU1,'bla-bla')
																			)
	AND NOT EXISTS(SELECT * FROM dbo.t_260order_ONK WHERE rf_idCase=c.id)
GROUP BY f.CodeM,a.Account,c.idRecordCase,c.rf_idSubMO ,c.rf_idDepartmentMO ,a.ReportMonth,c.AmountPayment
)
SELECT * from cte WHERE AmountPay>0