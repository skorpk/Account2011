USE RegisterCases
GO
SELECT p.*,cb.TypePay,cb.rf_idRecordCaseBack
FROM dbo.t_RecordCaseBack rb INNER JOIN dbo.t_PatientBack p ON
			rb.id=p.rf_idRecordCaseBack
								INNER JOIN dbo.t_CaseBack cb ON
            cb.rf_idRecordCaseBack = rb.id
WHERE rb.rf_idCase IN(135176990,135176991)

BEGIN TRANSACTION
DELETE FROM dbo.t_PatientBack WHERE rf_idRecordCaseBack=133361987

INSERT t_PatientBack
SELECT 133361987, rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,
                 OKATO,
                 AttachCodeM,
                 ENP,
                 CodeSMO34 FROM dbo.t_PatientBack WHERE rf_idRecordCaseBack=133361986

SELECT p.*,cb.TypePay,cb.rf_idRecordCaseBack
FROM dbo.t_RecordCaseBack rb INNER JOIN dbo.t_PatientBack p ON
			rb.id=p.rf_idRecordCaseBack
								INNER JOIN dbo.t_CaseBack cb ON
            cb.rf_idRecordCaseBack = rb.id
WHERE rb.rf_idCase IN(135176990,135176991)

commit

--BEGIN TRANSACTION
--UPDATE dbo.t_CaseBack SET TypePay=2 WHERE rf_idRecordCaseBack=133361987
--ROLLBACK