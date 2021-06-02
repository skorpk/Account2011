USE RegisterCases
GO
DECLARE @codeSMO VARCHAR(5)='34001'	
SELECT CAST(acn.DateRegistration AS DATE) AS DateRegistration,f.CodeM,RTRIM(p.rf_idSMO)+'-'+CAST(ab.NumberRegister AS VARCHAR(8))+'-'+CAST(ab.PropertyNumberRegister as char(1))+mu.AccountParam as NSCHET,a.ReportMonth,a.ReportYear
		,c.GUID_Case,p.rf_idSMO AS CodeSMO,acn.DateRegister AS DateAccount,acn.idRecordCase AS NumberCase
INTO #tmpCaseNovember
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN (SELECT MU,AccountParam from AccountOMS.dbo.vw_sprMuWithParamAccount 
								union ALL 
								select MU,AccountParam from vw_sprCSGWithParamAccount								                              
								) mu ON
			m.MES=mu.MU        				
					INNER JOIN dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN dbo.t_RegisterCaseBack ab ON
			rb.rf_idRegisterCaseBack=ab.id                  
					INNER JOIN dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack
					INNER JOIN dbo.t_PatientBack p ON
			rb.id=p.rf_idRecordCaseBack
					INNER JOIN (VALUES ('34001'),('34002'),('34006')) v(m) ON
			p.rf_idSMO=v.m
					inner JOIN dbo.vw_CaseInAccountsNovember acn ON
			f.CodeM=acn.CodeM                  
			AND p.rf_idSMO=acn.PrefixNumberRegister
			AND ab.NumberRegister=acn.NumberRegister
			AND ab.PropertyNumberRegister=acn.PropertyNumberRegister
			AND mu.AccountParam=acn.Letter
			AND c.GUID_Case=acn.GUID_Case                  
WHERE f.DateRegistration>'20151101' AND f.DateRegistration<'20151205' AND a.ReportYear=2015 AND a.ReportMonth=11 AND c.rf_idV006=1
		AND cb.TypePay=1 
ORDER BY CodeM

SELECT DateRegistration,f.CodeM, l.NameS ,CodeSMO,NSCHET,DateAccount ,ReportMonth ,ReportYear ,GUID_Case, NumberCase 
FROM #tmpCaseNovember f INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
WHERE CodeSMO=@codeSMO	ORDER BY DateRegistration
----------------------------------------------------------------------------------------------------
SET @codeSMO='34002'
SELECT DateRegistration,f.CodeM, l.NameS ,CodeSMO,NSCHET,DateAccount ,ReportMonth ,ReportYear ,GUID_Case, NumberCase 
FROM #tmpCaseNovember f INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
WHERE CodeSMO=@codeSMO	ORDER BY DateRegistration
----------------------------------------------------------------------------------------------------
SET @codeSMO='34006'
SELECT DateRegistration,f.CodeM, l.NameS ,CodeSMO,NSCHET,DateAccount ,ReportMonth ,ReportYear ,GUID_Case, NumberCase 
FROM #tmpCaseNovember f INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
WHERE CodeSMO=@codeSMO	ORDER BY DateRegistration

----------------------------------------------------------------------------------------------------
--SELECT DateRegistration,f.CodeM, l.NameS ,CodeSMO,NSCHET,DateAccount ,ReportMonth ,ReportYear ,GUID_Case, NumberCase 
--FROM #tmpCaseNovember f INNER JOIN dbo.vw_sprT001 l ON
--			f.CodeM=l.CodeM
--WHERE CodeSMO NOT IN('34001','34002','34006') ORDER BY DateRegistration
go
DROP TABLE #tmpCaseNovember
