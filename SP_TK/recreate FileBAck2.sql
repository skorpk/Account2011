USE RegisterCases
GO
SELECT c.id
INTO #t
FROM dbo.t_RecordCase r INNER JOIN dbo.t_Case c on
		r.id=c.rf_idRecordCase		
						INNER JOIN dbo.t_CompletedCase cc ON
		c.rf_idRecordCase=cc.rf_idRecordCase
WHERE r.ID_Patient IN ('E06D85AA-AEC3-3A17-5B36-F3BC600E1869')

SELECT e.*
FROM dbo.t_ErrorProcessControl e INNER JOIN #t t ON
			e.rf_idCase=t.id

BEGIN TRANSACTION
SELECT 'BEFORE',cb.* ,r.IdStep, rf_idCase
FROM dbo.t_RecordCaseBack r INNER JOIN dbo.t_CaseBack cb ON
			r.id=cb.rf_idRecordCaseBack
					 INNER JOIN #t t ON
			r.rf_idCase=t.id
ORDER BY rf_idCase,IdStep
										 
SELECT 'BEFORE',pb.* 
FROM dbo.t_RecordCaseBack r INNER JOIN dbo.t_PatientBack pb ON
			r.id=pb.rf_idRecordCaseBack
						 INNER JOIN #t t ON
			r.rf_idCase=t.id

UPDATE dbo.t_RecordCaseBack SET IdStep=0 WHERE id IN (103973302)

UPDATE dbo.t_CaseBack SET TypePay=1 WHERE rf_idRecordCaseBack IN (103973302)

DELETE FROM dbo.t_ErrorProcessControl WHERE rf_idCase IN(105753835)

UPDATE dbo.t_PatientBack SET AttachCodeM='174601' WHERE rf_idRecordCaseBack=103973302

SELECT pb.* ,cb.TypePay,r.IdStep
FROM dbo.t_RecordCaseBack r INNER JOIN dbo.t_PatientBack pb ON
			r.id=pb.rf_idRecordCaseBack
							INNER JOIN dbo.t_CaseBack cb ON
			r.id=cb.rf_idRecordCaseBack                          
							INNER JOIN #t t ON
			r.rf_idCase=t.id
--commit
ROLLBACK

go
DROP TABLE #t
