USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='256501' AND ReportYear=2013 AND NumberRegister=102
EXEC dbo.usp_RunTestsDefineSMOCreateSPTK @idFile 
