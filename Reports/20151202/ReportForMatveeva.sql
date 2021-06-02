USE RegisterCases
GO
SELECT f.CodeM,l.NameS,m.MES,mu.MUName
		,COUNT(CASE WHEN p.rf_idSMO = '34001' THEN c.id ELSE NULL END) AS '34001'
		,COUNT(CASE WHEN p.rf_idSMO = '34002' THEN c.id ELSE NULL END) AS '34002'
		,COUNT(CASE WHEN p.rf_idSMO = '34006' THEN c.id ELSE NULL END) AS '34006'
		,COUNT(CASE WHEN p.rf_idSMO NOT in ('34001','34002','34006') THEN c.id ELSE NULL END) AS '34'
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN (SELECT MU,MUName FROM dbo.vw_sprMUCompletedCase
								UNION ALL
								SELECT code,name FROM dbo.vw_sprCSG								                              
								) mu ON
			m.MES=mu.MU                              
					INNER JOIN dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack
					INNER JOIN dbo.t_PatientBack p ON
			rb.id=p.rf_idRecordCaseBack
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM                  
WHERE f.DateRegistration>'20151101' AND a.ReportYear=2015 AND a.ReportMonth=11 AND c.rf_idV006=1 --(1,2) AND c.rf_idV008 IN (31,32)
		AND cb.TypePay=1
GROUP BY f.CodeM,l.NameS,m.MES,mu.MUName
ORDER BY CodeM,MES