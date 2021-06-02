USE RegisterCases
GO
if OBJECT_ID('t_Kiro',N'U') is not null
	drop table t_Kiro
go
CREATE TABLE t_Kiro
(
	rf_idCase BIGINT NOT NULL,
	rf_idKiro INT NOT NULL,
	ValueKiro DECIMAL(3,2) NOT NULL
)
GO
ALTER TABLE dbo.t_Kiro  WITH CHECK ADD  CONSTRAINT [FK_Kiro_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO	
ALTER TABLE t_Kiro CHECK CONSTRAINT [FK_Kiro_Cases]
GO
	 
if OBJECT_ID('t_AdditionalCriterion',N'U') is not null
	drop table t_AdditionalCriterion
go
CREATE TABLE t_AdditionalCriterion
(
	rf_idCase BIGINT NOT NULL,
	rf_idAddCretiria VARCHAR(20) NOT NULL
)
go
ALTER TABLE dbo.t_AdditionalCriterion  WITH CHECK ADD  CONSTRAINT [FK_AdditionalCriterion_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO
ALTER TABLE t_AdditionalCriterion CHECK CONSTRAINT [FK_AdditionalCriterion_Cases]
GO
ALTER TABLE dbo.t_RecordCase ADD MSE TINYINT NULL
go
-------------------------------------------------------
USE AccountOMS
GO
if OBJECT_ID('t_Kiro',N'U') is not null
	drop table t_Kiro
go
CREATE TABLE t_Kiro
(
	rf_idCase BIGINT NOT NULL,
	rf_idKiro INT NOT NULL,
	ValueKiro DECIMAL(3,2) NOT NULL
)
GO
ALTER TABLE dbo.t_Kiro  WITH CHECK ADD  CONSTRAINT [FK_Kiro_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO	
ALTER TABLE t_Kiro CHECK CONSTRAINT [FK_Kiro_Cases]
GO

if OBJECT_ID('t_AdditionalCriterion',N'U') is not null
	drop table t_AdditionalCriterion
go
CREATE TABLE t_AdditionalCriterion
(
	rf_idCase BIGINT NOT NULL,
	rf_idAddCretiria VARCHAR(20) NOT NULL
)
GO
ALTER TABLE dbo.t_AdditionalCriterion  WITH CHECK ADD  CONSTRAINT [FK_AdditionalCriterion_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO
ALTER TABLE t_AdditionalCriterion CHECK CONSTRAINT [FK_AdditionalCriterion_Cases]
GO
ALTER TABLE dbo.t_RecordCasePatient ADD MSE TINYINT NULL
go