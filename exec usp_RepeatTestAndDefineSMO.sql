USE RegisterCases
go
SET NOCOUNT ON

declare @idFile INT

--SET STATISTICS TIME ON
--SET STATISTICS IO ON

SELECT @idFile=f.id 
from vw_getIdFileNumber f 
WHERE ReportYear=2016 AND f.CountSluch>10 AND NOT EXISTS(SELECT * FROM dbo.vw_getFileBack WHERE ReportYear=2016 AND rf_idFiles=f.id)--CodeM='103001' AND NumberRegister=16
ORDER BY DateRegistration

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

EXEC dbo.usp_RunRepeatTestAndDefineSMO @idFile
go
--SET STATISTICS TIME OFF
--SET STATISTICS IO OFF

