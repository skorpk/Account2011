USE RegisterCases
go
SET NOCOUNT ON

declare @idFile int=18715
----------delete group--------------
delete from t_FileBack where rf_idFiles=@idFile
delete from t_ErrorProcessControl where rf_idFile=@idFile
delete from t_RefCasePatientDefine where rf_idFiles=@idFile

---------execute group--------------
exec usp_RunTestsDefineSMOCreateSPTK @idFile

go