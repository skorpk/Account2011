USE RegisterCases
GO
SELECT COUNT(*) FROM dbo.t_ErrorProcessControl WHERE rf_idFile<152478 AND DateRegistration<'20190201'
go
BEGIN TRANSACTION
	DELETE TOP (10000) FROM dbo.t_ErrorProcessControl WHERE rf_idFile<152478 AND DateRegistration<'20190201'
COMMIT
GO 5
SELECT COUNT(*) FROM dbo.t_ErrorProcessControl WHERE rf_idFile<152478 AND DateRegistration<'20190201'