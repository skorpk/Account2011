USE RegisterCases
GO								  
;WITH cteFile
AS(
SELECT  fb.CodeM ,
        fb.rf_idFiles ,
        fb.idFileBack ,
        fb.UserName ,
        fb.DateCreate ,
        fb.NumberRegister ,
        fb.PropertyNumberRegister, f.CountSluch, f.FileNameHR         
FROM dbo.vw_getIdFileNumber f INNER JOIN dbo.vw_getFileBack fb ON
				f.id=fb.rf_idFiles
WHERE f.ReportYear=2018 AND DateRegistration>'20180807' AND DateRegistration<'20180813'
)
SELECT *
INTO #t
FROM cteFile c1 
WHERE c1.PropertyNumberRegister=1 AND NOT EXISTS(SELECT * FROM cteFile c2 WHERE c2.rf_idFiles=c1.rf_idFiles AND PropertyNumberRegister=2)

SELECT *
FROM #t t
WHERE NOT EXISTS(SELECT * FROM dbo.t_RefCasePatientDefine WHERE rf_idFiles=t.rf_idFiles AND IsUnloadIntoSP_TK IS null)

SELECT *
FROM dbo.t_RefCasePatientDefine r INNER JOIN #t t ON
				r.rf_idFiles=t.rf_idFiles
WHERE r.IsUnloadIntoSP_TK IS NULL and NOT EXISTS(SELECT * FROM dbo.t_CaseDefineZP1 WHERE rf_idRefCaseIteration=r.id)
GO
DROP TABLE #t