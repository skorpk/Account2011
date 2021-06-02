USE RegisterCases
GO
GRANT SELECT ON dbo.vw_AmbCaseNotExistInAccount TO db_RegisterCase
go
USE AccountOMS
GO
GRANT SELECT ON dbo.vw_AmbCaseInAccountFin TO db_AccountOMS
GRANT SELECT ON dbo.vw_AmbCaseInAccountWithoutFin TO db_AccountOMS
