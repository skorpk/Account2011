USE RegisterCasesTest
GO
--delete FROM dbo.t_FileBack WHERE rf_idFiles=66561

SET STATISTICS TIME ON
exec dbo.usp_RunRepeatTestAndDefineSMO @idFile=66561
SET STATISTICS TIME OFF
--SELECT * FROM dbo.vw_getIdFileNumber WHERE id=66561