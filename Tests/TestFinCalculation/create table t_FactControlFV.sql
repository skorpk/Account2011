USE RegisterCases
GO
IF OBJECT_ID('t_FactControlFV',N'U') IS NOT NULL
	DROP TABLE t_FactControlFV
GO
CREATE TABLE t_FactControlFV
(
	CodeM CHAR(6),
	ReportYear SMALLINT,
	[quarter] tinyint,
	idFile int,
	PropertyNumber TINYINT,
	unitCode smallint,
	CodeFV smallint,
	SumAmount  decimal(15,2)
)
GO
CREATE NONCLUSTERED INDEX IX_FactControlFV ON dbo.t_FactControlFV( CodeM,ReportYear,[Quarter],unitCode,CodeFV,idfile) INCLUDE(SumAmount,PropertyNumber)
GO
CREATE UNIQUE NONCLUSTERED INDEX QU_FactControlFV_IFile_Property ON dbo.t_FactControlFV( idfile,PropertyNumber,unitCode,CodeFV) WITH IGNORE_DUP_KEY
GO

go
GRANT SELECT,UPDATE,INSERT,DELETE ON dbo.t_FactControlFV TO db_RegisterCase
go