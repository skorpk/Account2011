USE RegisterCases
GO
;WITH cte
AS(
SELECT f.CodeM,a.NumberRegister,c.rf_idRecordCase
FROM t_File f INNER JOIN dbo.t_RegistersCase a ON
		f.id=a.rf_idFiles
			inner join dbo.t_RecordCase r ON
		a.id=r.rf_idRegistersCase
				INNER JOIN dbo.t_Case c on
		r.id=c.rf_idRecordCase								
WHERE c.DateEnd>='20190101' AND a.ReportYear=2019 AND f.DateRegistration>'20190110'
GROUP BY f.CodeM,a.NumberRegister,c.rf_idRecordCase
HAVING COUNT(*)=2
)
SELECT cc.id,cc.rf_idRecordCase,CodeM,NumberRegister
INTO #t
FROM cte c INNER JOIN dbo.t_Case cc ON
		c.rf_idRecordCase=cc.rf_idRecordCase

SELECT DISTINCT codeM, NumberRegister FROM #t

SELECT e.*
FROM dbo.t_ErrorProcessControl e INNER JOIN #t t ON
			e.rf_idCase=t.id
WHERE ErrorNumber=55

;WITH cteA
AS(
SELECT cb.* ,r.IdStep, r.rf_idCase, r.rf_idRecordCase, CodeM,NumberRegister
FROM dbo.t_RecordCaseBack r INNER JOIN dbo.t_CaseBack cb ON
			r.id=cb.rf_idRecordCaseBack
					 INNER JOIN #t t ON
			r.rf_idRecordCase=t.rf_idRecordCase
			AND r.rf_idCase<>t.id
)
, cteB as
(
 SELECT cb.* ,r.IdStep, r.rf_idCase, r.rf_idRecordCase
FROM dbo.t_RecordCaseBack r INNER JOIN dbo.t_CaseBack cb ON
			r.id=cb.rf_idRecordCaseBack
					 INNER JOIN #t t ON
			r.rf_idCase=t.id
)
SELECT a.rf_idCase,b.rf_idCase, a.TypePay AS Type1, b.TypePay AS Type2 ,CodeM,NumberRegister
FROM cteA a INNER JOIN cteB b ON
		a.rf_idRecordCase=b.rf_idRecordCase
		and a.rf_idRecordCaseBack<>b.rf_idRecordCaseBack
WHERE a.TypePay<>b.TypePay
ORDER BY a.rf_idCase
										 

GO
DROP TABLE #t