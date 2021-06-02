USE AccountOMS
GO
SELECT f.CodeM,l.NAMES
		,SUM(CASE WHEN r.AttachLPU<>'000000' THEN 1 ELSE 0 END) AS CountAttachLPU
		,SUM(CASE WHEN r.AttachLPU='000000' THEN 1 ELSE 0 END) AS CountNotAttachLPU
		,COUNT(r.AttachLPU) AS CountAll
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				  INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
			--AND l.pfa=1
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014 AND a.rf_idSMO<>'34'-- AND a.PropertyNumberRegister<>2
		AND a.Letter IN ('O','R','F','V','U')
GROUP BY f.CodeM,l.NAMES
ORDER BY f.CodeM

/*
SELECT f.CodeM
		,SUM(CASE WHEN r.AttachLPU<>f.CodeM AND r.AttachLPU<>'000000' THEN 1 ELSE 0 END) AS CountOtherAttachLPU
		,SUM(CASE WHEN r.AttachLPU=f.CodeM AND r.AttachLPU<>'000000' THEN 1 ELSE 0 END) AS CountAttachLPU
		,COUNT(r.AttachLPU) AS CountAllAttachLPU		
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
			AND l.pfa=1
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2014 AND a.rf_idSMO<>'34'-- AND a.PropertyNumberRegister<>2
GROUP BY f.CodeM
*/