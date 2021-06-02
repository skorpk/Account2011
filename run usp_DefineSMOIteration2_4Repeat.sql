USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2013 AND CodeM='135020' AND NumberRegister=53

EXEC dbo.usp_DefineSMOIteration2_4Repeat @id=@idFile  -- int
