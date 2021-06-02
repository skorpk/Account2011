USE RegisterCases
GO

--SELECT *
--FROM dbo.t_Case WHERE GUID_Case='7C8805AE-207F-680E-6AE4-96BDE778B319'

--SELECT * 
--FROM dbo.t_RefCasePatientDefine d INNER JOIN dbo.t_CaseDefineZP1Found z ON
--			d.id=z.rf_idRefCaseIteration
--WHERE rf_idCase=119999993

SELECT *
FROM dbo.t_RegisterCaseBack r INNER join dbo.t_RecordCaseBack d ON
			r.id=d.rf_idRegisterCaseBack
						INNER JOIN dbo.t_PatientBack p ON
			d.id=p.rf_idRecordCaseBack
					 INNER JOIN dbo.t_CaseBack c ON
			p.rf_idRecordCaseBack=c.rf_idRecordCaseBack
WHERE c.TypePay=1 AND ENP IS NULL AND r.ReportYear=2019 AND r.ReportMonth>1

--BEGIN TRANSACTION
--	UPDATE dbo.t_PatientBack SET ENP=NumberPolis WHERE rf_idRecordCaseBack=118399098
--commit