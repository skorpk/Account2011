USE RegisterCases
GO
GRANT INSERT,SELECT ON dbo.t_NextVisitDate TO db_RegisterCase
GO
USE AccountOMS
GO
GRANT INSERT,SELECT ON dbo.t_NextVisitDate TO db_AccountOMS
go