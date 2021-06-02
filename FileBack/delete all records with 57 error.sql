USE RegisterCases
GO

BEGIN TRANSACTION
DELETE FROM dbo.t_ErrorProcessControl
FROM t_File f INNER JOIN dbo.t_ErrorProcessControl e ON
		f.id=e.rf_idFile
				INNER JOIN dbo.t_RefCasePatientDefine r ON
			e.rf_idCase=r.rf_idCase
WHERE f.DateRegistration>'20180201' AND f.DateRegistration<GETDATE() AND e.ErrorNumber=57 AND r.IsUnloadIntoSP_TK IS NULL
	AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE ErrorNumber<>57 AND rf_idCase=e.rf_idCase)

SELECT COUNT(e.rf_idCase)
FROM t_File f INNER JOIN dbo.t_ErrorProcessControl e ON
		f.id=e.rf_idFile
				INNER JOIN dbo.t_RefCasePatientDefine r ON
			e.rf_idCase=r.rf_idCase
WHERE f.DateRegistration>'20180201' AND f.DateRegistration<GETDATE() AND e.ErrorNumber=57 AND r.IsUnloadIntoSP_TK IS NULL
	AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE ErrorNumber<>57 AND rf_idCase=e.rf_idCase)


commit

