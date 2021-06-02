USE RegisterCases
go
declare @idFile int
select @idFile=id from vw_getIdFileNumber where CodeM='102604' and NumberRegister=27 and ReportYear=2015
SELECT @idFile
select * from vw_getIdFileNumber where id=@idFile

EXEC dbo.usp_RunRepeatTestAndDefineSMO @idFile

go