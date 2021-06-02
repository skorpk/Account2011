USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='124530' and NumberRegister=53 and ReportYear=2018

select * from vw_getIdFileNumber where id=@idFile

 