USE RegisterCases
GO
exec usp_GetProcessingZP1Data

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=127184

DECLARE @idRecordCaseNext as TVP_CasePatient
INSERT @idRecordCaseNext
SELECT rf_idCase,rf_idRegisterPatient
FROM dbo.t_RefCasePatientDefine WHERE rf_idFiles=127184 AND IsUnloadIntoSP_TK IS null

exec usp_DefineSMOIteration2_4 127184,2,'HRM395301T34_180100002'