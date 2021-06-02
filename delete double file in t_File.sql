USE RegisterCases
GO
SELECT *
FROM dbo.vw_getIdFileNumber WHERE CodeM='141023' AND ReportYear=2018 AND NumberRegister=27

BEGIN TRANSACTION
DECLARE @idFile int=128715

delete from t_FileBack where rf_idFiles=@idFile
delete from t_RefCasePatientDefine where rf_idFiles=@idFile
delete from t_ErrorProcessControl where rf_idFile=@idFile
delete from t_File where id=@idFile

SELECT * FROM dbo.vw_getFileBack WHERE rf_idFiles IN(128714,128715)

commit