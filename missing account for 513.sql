USE AccountOMS
GO

SELECT c.CodeM,c.Account 
FROM (
		SELECT c.GUID_Case,a.Account,f.CodeM
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
		WHERE f.DateRegistration>'20140223' AND a.ReportYear=2014 AND r.AttachLPU<>c.rf_idMO AND a.Letter IN ('O','R','F','V','U')
	) c INNER JOIN RegisterCases.dbo.t_Case c1 ON  	                                    
		c.GUID_Case=c1.GUID_Case
		INNER JOIN RegisterCases.dbo.t_RefCaseAttachLPUItearion2 ra ON
			c1.id=ra.rf_idCase
GROUP BY c.CodeM,c.Account 
--SELECT *
--FROM RegisterCases.dbo.t_RefCasePatientDefine r INNER JOIN RegisterCases.dbo.t_CasePatientDefineIteration i ON
--			r.id=i.rf_idRefCaseIteration
--WHERE rf_idCase=33357658			