USE RegisterCases
GO
DECLARE @codeM CHAR(6)='101801'

--SELECT * FROM dbo.tmpWrongCaseNovember WHERE CodeM=@codeM

SELECT f.DateRegistration ,f.CodeM,c.GUID_Case,p.rf_idSMO AS CodeSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
			--AND f.CodeM=@codeM
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase			
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
WHERE f.DateRegistration>'20151207' AND f.DateRegistration<'20151210' AND a.ReportYear=2015 AND a.ReportMonth=11 AND c.rf_idV006=1
		AND cb.TypePay=1 AND EXISTS(SELECT * FROM dbo.tmpWrongCaseNovember wc WHERE wc.GUID_Case=c.GUID_Case)
ORDER BY CodeM


SELECT f.DateRegistration ,f.CodeM,c.GUID_Case,p.rf_idSMO AS CodeSMO
--INTO #tmpCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND f.CodeM=@codeM
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase					
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
WHERE f.DateRegistration>'20151207' AND f.DateRegistration<'20151209' AND a.ReportYear=2015 AND a.ReportMonth=11 AND c.rf_idV006=1
		AND cb.TypePay=1 AND NOT EXISTS(SELECT * FROM dbo.tmpWrongCaseNovember wc WHERE wc.GUID_Case=c.GUID_Case)
ORDER BY CodeM

--SELECT f.DateRegistration,cb.TypePay,ab.DateCreate,a.ReportMonth,a.ReportYear,c.GUID_Case,f.CodeM,c.rf_idV006
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
--			f.id=a.rf_idFiles
--					INNER JOIN dbo.t_RecordCase r ON
--			a.id=r.rf_idRegistersCase
--					INNER JOIN dbo.t_Case c ON
--			r.id=c.rf_idRecordCase												
--					INNER JOIN dbo.t_RecordCaseBack rb ON
--			c.id=rb.rf_idCase
--					INNER JOIN dbo.t_RegisterCaseBack ab ON
--			rb.rf_idRegisterCaseBack=ab.id                  
--					INNER JOIN dbo.t_CaseBack cb ON
--			rb.id=cb.rf_idRecordCaseBack	
--					INNER JOIN dbo.t_PatientBack p ON
--			rb.id=p.rf_idRecordCaseBack
--WHERE EXISTS(SELECT * FROM #tmpCase WHERE GUID_Case=c.GUID_Case)
--ORDER BY cb.TypePay,c.GUID_Case
--go
--drop TABLE #tmpCase