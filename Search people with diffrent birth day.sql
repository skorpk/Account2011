USE RegisterCases
GO
DECLARE @dtStart DATETIME='20150125',
		@dtEnd DATETIME='20150406' ,
		@reportYear SMALLINT=2015
SET STATISTICS TIME ON
SET STATISTICS IO ON
SELECT rd.rf_idCase,rd.rf_idRegisterPatient,pol.ID AS PID, pol.Fam,pol.IM,CAST(pol.DR AS DATE) AS DR
INTO #t1
FROM dbo.t_RefCasePatientDefine rd INNER JOIN dbo.t_CaseDefine cd ON
			rd.id=cd.rf_idRefCaseIteration
							INNER JOIN PolicyRegister.dbo.PEOPLE pol ON
			cd.PID=pol.ID
								INNER JOIN dbo.t_File f ON
			rd.rf_idFiles=f.id
							INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear

SELECT  t.rf_idCase,t.rf_idRegisterPatient,t.PID,p.Fam,p.Im,p.BirthDay,t.FAM AS Fam_Pol,t.IM AS Im_pol,t.DR
		,DATEDIFF(YEAR,t.DR,p.BirthDay) AS DateDiffYear
FROM #t1 t INNER JOIN dbo.t_RegisterPatient p ON
		t.rf_idRegisterPatient=p.id
WHERE p.BirthDay <>t.DR		
ORDER BY DateDiffYear	
SET STATISTICS TIME OFF
SET STATISTICS IO OFF

----------------------------------------------------------------------------------------------------------------------------
GO
DROP TABLE #t1
