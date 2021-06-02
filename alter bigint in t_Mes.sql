USE RegisterCases
GO
/****** Object:  Index [IX_idCase]    Script Date: 05/25/2015 09:56:16 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_MES]') AND name = N'IX_idCase')
DROP INDEX [IX_idCase] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_MES_AccountOMS]    Script Date: 05/25/2015 09:56:46 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_MES]') AND name = N'IX_MES_AccountOMS')
DROP INDEX [IX_MES_AccountOMS] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Mes_Case_Quantity]    Script Date: 05/25/2015 09:57:09 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_MES]') AND name = N'IX_Mes_Case_Quantity')
DROP INDEX [IX_Mes_Case_Quantity] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
GO	
/****** Object:  Index [IX_MES_Quantity]    Script Date: 05/25/2015 09:58:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_MES]') AND name = N'IX_MES_Quantity')
DROP INDEX [IX_MES_Quantity] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [IX_MES_Tariff]    Script Date: 05/25/2015 09:58:45 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_MES]') AND name = N'IX_MES_Tariff')
DROP INDEX [IX_MES_Tariff] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [QU_MES_Case]    Script Date: 05/25/2015 09:59:05 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_MES]') AND name = N'QU_MES_Case')
DROP INDEX [QU_MES_Case] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MES_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[t_MES]'))
ALTER TABLE [dbo].[t_MES] DROP CONSTRAINT [FK_MES_Cases]
GO
/****** Object:  Index [IX_CaseMUCodeV004]    Script Date: 05/25/2015 10:20:08 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_Meduslugi]') AND name = N'IX_CaseMUCodeV004')
DROP INDEX [IX_CaseMUCodeV004] ON [dbo].[t_Meduslugi] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Meduslugi_Case]    Script Date: 05/25/2015 10:20:30 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_Meduslugi]') AND name = N'IX_Meduslugi_Case')
DROP INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi] WITH ( ONLINE = OFF )
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Meduslugi_Cases]') AND parent_object_id = OBJECT_ID(N'[dbo].[t_Meduslugi]'))
ALTER TABLE [dbo].[t_Meduslugi] DROP CONSTRAINT [FK_Meduslugi_Cases]
GO
/****** Object:  Index [IX_Diagnosis_RefCase2]    Script Date: 05/25/2015 13:02:26 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_Diagnosis]') AND name = N'IX_Diagnosis_RefCase2')
DROP INDEX [IX_Diagnosis_RefCase2] ON [dbo].[t_Diagnosis] WITH ( ONLINE = OFF )
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Diagnosis_Cases2]') AND parent_object_id = OBJECT_ID(N'[dbo].[t_Diagnosis]'))
ALTER TABLE [dbo].[t_Diagnosis] DROP CONSTRAINT [FK_Diagnosis_Cases2]
GO
-----------------------
----------------------------Alter column-----------------------------------------------
 ALTER TABLE  t_Mes ALTER COLUMN rf_idCase int NOT null
 go
 ----------------------Meduslugi-------------------------------------------------------
ALTER TABLE dbo.t_Meduslugi ADD rf_idCase2 INT NOT NULL DEFAULT 0
GO
UPDATE dbo.t_Meduslugi SET rf_idCase2=rf_idCase
GO
EXEC sp_rename 'dbo.t_Meduslugi.rf_idCase', 'rf_idCaseOld', 'COLUMN';
go
EXEC sp_rename 'dbo.t_Meduslugi.rf_idCase2', 'rf_idCase', 'COLUMN';
go
ALTER TABLE dbo.t_Diagnosis ALTER COLUMN rf_idCase int NOT null
----------------------------Create indexes-----------------------------------------------
Go

ALTER TABLE [dbo].[t_MES] CHECK CONSTRAINT [FK_MES_Cases]
GO
/****** Object:  Index [QU_MES_Case]    Script Date: 05/25/2015 09:59:05 ******/
CREATE UNIQUE NONCLUSTERED INDEX [QU_MES_Case] ON [dbo].[t_MES] 
(
	[rf_idCase] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_MES_Tariff]    Script Date: 05/25/2015 09:58:45 ******/
CREATE NONCLUSTERED INDEX [IX_MES_Tariff] ON [dbo].[t_MES] 
(
	[Tariff] ASC
)
INCLUDE ( [rf_idCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_MES_Quantity]    Script Date: 05/25/2015 09:58:01 ******/
CREATE NONCLUSTERED INDEX [IX_MES_Quantity] ON [dbo].[t_MES] 
(
	[Quantity] ASC
)
INCLUDE ( [rf_idCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_idCase]    Script Date: 05/25/2015 09:56:31 ******/
CREATE NONCLUSTERED INDEX [IX_idCase] ON [dbo].[t_MES] 
(
	[rf_idCase] ASC
)
INCLUDE ( [MES],
[Quantity],
[Tariff]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_MES_AccountOMS]    Script Date: 05/25/2015 09:56:47 ******/
CREATE NONCLUSTERED INDEX [IX_MES_AccountOMS] ON [dbo].[t_MES] 
(
	[MES] ASC
)
INCLUDE ( [rf_idCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_Mes_Case_Quantity]    Script Date: 05/25/2015 09:57:09 ******/
CREATE NONCLUSTERED INDEX [IX_Mes_Case_Quantity] ON [dbo].[t_MES] 
(
	[rf_idCase] ASC
)
INCLUDE ( [MES],
[Quantity]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
 GO
/****** Object:  Index [IX_Meduslugi_Case]    Script Date: 05/25/2015 10:20:30 ******/
CREATE NONCLUSTERED INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi] 
(
	[rf_idCase] ASC
)
INCLUDE ( [id],
[GUID_MU],
[rf_idMO],
[DiagnosisCode],
[rf_idV004],
[DateHelpBegin],
[DateHelpEnd],
[IsChildTariff],
[MUCode],
[Quantity],
[Price],
[rf_idV002],
[TotalPrice],
[Comments]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_CaseMUCodeV004]    Script Date: 05/25/2015 10:20:09 ******/
CREATE NONCLUSTERED INDEX [IX_CaseMUCodeV004] ON [dbo].[t_Meduslugi] 
(
	[rf_idCase] ASC,
	[MUCode] ASC,
	[rf_idV004] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
/****** Object:  Index [IX_Diagnosis_RefCase2]    Script Date: 05/25/2015 13:02:26 ******/
CREATE NONCLUSTERED INDEX [IX_Diagnosis_RefCase2] ON [dbo].[t_Diagnosis] 
(
	[rf_idCase] ASC
)
INCLUDE ( [DiagnosisCode],
[TypeDiagnosis]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO

----------------------------------------------------FK---------------------------------------------------
ALTER TABLE [dbo].[t_Meduslugi]  WITH NOCHECK ADD  CONSTRAINT [FK_Meduslugi_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[t_Meduslugi] NOCHECK CONSTRAINT [FK_Meduslugi_Cases]
GO
ALTER TABLE [dbo].[t_Diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_Diagnosis_Cases2] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO 
ALTER TABLE [dbo].[t_Diagnosis] CHECK CONSTRAINT [FK_Diagnosis_Cases2]
GO
ALTER TABLE [dbo].[t_MES]  WITH CHECK ADD  CONSTRAINT [FK_MES_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO


