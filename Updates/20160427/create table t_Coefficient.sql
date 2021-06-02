USE AccountOMS
GO
CREATE TABLE t_Coefficient
(
	rf_idCase BIGINT,
	Code_SL SMALLINT,
	Coefficient DECIMAL(3,2)
)
GO
ALTER TABLE dbo.t_Case ADD IT_SL DECIMAL(3,2)
go