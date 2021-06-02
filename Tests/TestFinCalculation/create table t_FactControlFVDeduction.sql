USE RegisterCases
GO
IF OBJECT_ID('t_FactControlFVDeduction',N'U') IS NOT NULL
	DROP TABLE t_FactControlFVDeduction
GO
/*в данную таблиу скоадываются только снятия по МЭК*/
CREATE TABLE t_FactControlFVDeduction
(
	CodeM CHAR(6),
	ReportYear SMALLINT,
	[quarter] tinyint,
	unitCode smallint,
	CodeFV smallint,
	SumAmountDeduction  decimal(15,2)
)
GO
CREATE NONCLUSTERED INDEX IX_FactControlFVDeduction ON dbo.t_FactControlFVDeduction(CodeM,ReportYear,[Quarter],unitCode,CodeFV) INCLUDE(SumAmountDeduction)
GO

go
GRANT SELECT,UPDATE,INSERT,DELETE ON dbo.t_FactControlFVDeduction TO db_RegisterCase
go