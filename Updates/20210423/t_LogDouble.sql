USE RegisterCases
GO
IF OBJECT_ID('t_LogDouble',N'U') IS NOT NULL
	DROP TABLE t_LogDouble
go
CREATE TABLE t_LogDouble
(
	DateRegistration DATETIME NOT NULL DEFAULT(GETDATE()),
	rf_idFile INT NOT NULL,
	TotalRow INT NOT NULL,
    TypeQuery varchar(5)
)
go