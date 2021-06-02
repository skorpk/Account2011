USE AccountOMS
GO
--DROP TABLE tmp_Raschet_9

SELECT *
INTO tmp_Raschet_9
FROM (
SELECT f.DateRegistration, a.ReportYear, a.ReportMonth, c.rf_idV006, a.Letter, c.AmountPayment, ISNULL(r.AttachLPU,'000000') AS AttachLPU
	  ,c.id, m.MU, f.CodeM, a.rf_idSMO, CAST('0' AS VARCHAR(16)) AS MES, 0 AS Tariff, m.Quantity, m.Price	 
FROM dbo.t_File f INNER JOIN (SELECT a.* 
							  FROM dbo.t_RegistersAccounts a LEFT JOIN (VALUES('D'),('R'),('O'),('F'),('V'),('U'),('I')) v(Letter) ON
											
											a.Letter=v.Letter				
							  WHERE a.ReportYearMonth>201301 AND a.ReportYearMonth<201310 AND v.Letter IS null) a ON
		f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c WITH(INDEX(IX_Case_idRecordCasePatient_ID_DateEnd)) ON
		r.id=c.rf_idRecordCasePatient
		AND c.DateEnd>'20130101'
		AND c.DateEnd<'20131001'
		AND c.IsCompletedCase=0				
				INNER JOIN (SELECT m.* 
							FROM  dbo.t_Meduslugi m LEFT JOIN (SELECT MUGroupCode,MUUnGroupCode,MUCode 
															  FROM dbo.vw_sprMU 
															  WHERE MUGroupCode=57 OR (MU IN('60.2.5','2.78.5','2.79.6','2.81.6'))
															  ) m1 ON
											m.MUGroupCode=m1.MUGroupCode
											AND m.MUUnGroupCode=m1.MUUnGroupCode
											AND m.MUCode=m1.MUCode
							WHERE m1.MUGroupCode IS NULL															  
							) m on
		c.id=m.rf_idCase				
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' AND c.rf_idV006=3
UNION ALL
SELECT f.DateRegistration, a.ReportYear, a.ReportMonth, c.rf_idV006, a.Letter, c.AmountPayment, ISNULL(r.AttachLPU,'000000') AS AttachLPU
	  ,c.id, m.MU, f.CodeM, a.rf_idSMO,mes.MES, mes.Tariff, m.Quantity, m.Price	 
FROM dbo.t_File f INNER JOIN (SELECT a.* 
							  FROM dbo.t_RegistersAccounts a LEFT JOIN (VALUES('D'),('R'),('O'),('F'),('V'),('U'),('I')) v(Letter) ON
											
											a.Letter=v.Letter				
							  WHERE a.ReportYearMonth>201301 AND a.ReportYearMonth<201310 AND v.Letter IS null) a ON
		f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_Case c WITH(INDEX(IX_Case_idRecordCasePatient_ID_DateEnd)) ON
		r.id=c.rf_idRecordCasePatient
		AND c.DateEnd>'20130101'
		AND c.DateEnd<'20131001'
		AND c.IsCompletedCase=1		
				INNER JOIN (SELECT m.* 
							FROM  dbo.t_Meduslugi m LEFT JOIN (SELECT MUGroupCode,MUUnGroupCode,MUCode 
															  FROM dbo.vw_sprMU 
															  WHERE MUGroupCode=57 OR (MU IN('60.2.5','2.78.5','2.79.6','2.81.6'))
															  ) m1 ON
											m.MUGroupCode=m1.MUGroupCode
											AND m.MUUnGroupCode=m1.MUUnGroupCode
											AND m.MUCode=m1.MUCode
							WHERE m1.MUGroupCode IS NULL															  
							) m ON
		c.id=m.rf_idCase				
				INNER JOIN t_Mes mes ON
		c.id=mes.rf_idCase				
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<'20131008' AND c.rf_idV006=3
) t