USE RegisterCases
go
SET NOCOUNT ON

declare @idFile int
select @idFile=id from vw_getIdFileNumber where CodeM='124528' and NumberRegister=13 and ReportYear=2012
begin transaction

	delete from t_ErrorProcessControl where rf_idFile=@idFile

commit

exec usp_InsertLPUEnableCalendar '102506',0,'I'

exec usp_RunTestsDefineSMOCreateSPTK @idFile


go