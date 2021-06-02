USE RegisterCases
go
declare @idFile int

select top 1 @idFile=id from vw_getIdFileNumber where CodeM='124528' and NumberRegister=12 and ReportYear=2013

delete from t_FileBack where rf_idFiles=@idFile

delete from t_ErrorProcessControl where rf_idFile=@idFile

--SET STATISTICS TIME ON
	exec usp_RunRepeatTestAndDefineSMO @idFile
--SET STATISTICS TIME OFF
go