USE AccountOMSReports
GO
WITH Iter3_CTE
AS
(
SELECT c.id,pc.IDPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		  f.id=a.rf_idFiles  
		  AND a.rf_idSMO<>'34'   
			 INNER JOIN dbo.t_RecordCasePatient r ON
		  a.id=r.rf_idRegistersAccounts			
			 INNER JOIN dbo.t_Case c ON
		  r.id=c.rf_idRecordCasePatient	
			INNER JOIN (VALUES(3),(23) )v(sc) ON
		 c.IsSpecialCase=v.sc
			INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction
						FROM dbo.t_PaymentAcceptedCase 
						WHERE Letter='O' AND DateRegistration>'20140101' AND DateRegistration<'20141112'
						GROUP BY rf_idCase
						)	   p ON
		c.id=p.rf_idCase
			INNER JOIN dbo.t_People_Case pc ON
		c.id=pc.rf_idCase
WHERE a.Letter='O' AND f.DateRegistration>'20140101' AND f.DateRegistration<'20141112' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014
		 AND c.AmountPayment-p.AmountDeduction>0
) ,  Iter4_CTE 
AS
(
	SELECT c.id,pc.IDPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		  f.id=a.rf_idFiles  
		  AND a.rf_idSMO<>'34'   
			 INNER JOIN dbo.t_RecordCasePatient r ON
		  a.id=r.rf_idRegistersAccounts			
			 INNER JOIN dbo.t_Case c ON
		  r.id=c.rf_idRecordCasePatient	
			INNER JOIN (VALUES(4),(24) )v(sc) ON
		 c.IsSpecialCase=v.sc
			INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction
						FROM dbo.t_PaymentAcceptedCase 
						WHERE Letter='O' AND DateRegistration>'20140101' AND DateRegistration<'20141112'
						GROUP BY rf_idCase
						)	   p ON
		c.id=p.rf_idCase
			INNER JOIN dbo.t_People_Case pc ON
		c.id=pc.rf_idCase
WHERE a.Letter='O' AND f.DateRegistration>'20140101' AND f.DateRegistration<'20141112' AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=2014
		AND c.AmountPayment-p.AmountDeduction>0 
)
SELECT IDPeople,c.id
FROM Iter4_CTE c 
WHERE NOT EXISTS(SELECT * FROM Iter3_CTE WHERE IDPeople=c.IDPeople)
	