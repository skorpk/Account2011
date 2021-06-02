USE RegisterCases
GO
----------Add new columns
ALTER TABLE dbo.t_RecordCase ADD BirthWeight SMALLINT NULL;
ALTER TABLE dbo.t_Case ADD rf_idV014 TINYINT NULL;
ALTER TABLE dbo.t_Case ADD rf_idV018 VARCHAR(19) NULL;
ALTER TABLE dbo.t_Case ADD rf_idV019 smallint NULL;
ALTER TABLE dbo.t_Meduslugi ADD MUSurgery VARCHAR(16) NULL;
GO
-----------All indexes on table disable-------------------
DROP INDEX [IX_RecordCase_RefRegistersCase] ON [dbo].[t_RecordCase];
DROP INDEX [IX_Case_idRecordCase_ID] ON [dbo].[t_Case];
--------------------------------------------------------
DROP INDEX [IX_Mes_Case_Quantity] ON [dbo].[t_MES]
DROP INDEX [IX_idCase] ON [dbo].[t_MES]
DROP INDEX [IX_MES_AccountOMS] ON [dbo].[t_MES]
--------------------------------------------------------
DROP INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi]
DROP INDEX [IX_CaseMUCodeV004] ON [dbo].[t_Meduslugi]
GO

GO
ALTER TABLE dbo.t_RecordCase ALTER COLUMN idRecord INT NOT NULL;
-------------------------------------------------------------------
ALTER TABLE dbo.t_Case ALTER COLUMN	idRecordCase BIGINT NOT NULL;
ALTER TABLE dbo.t_Case ALTER COLUMN	rf_idSubMO varchar(8) NULL;
ALTER TABLE dbo.t_Case ALTER COLUMN	rf_idDoctor varchar(25) NULL;
-------------------------------------------------------------------
ALTER TABLE dbo.t_MES ALTER COLUMN MES varchar(20) NULL;
-------------------------------------------------------------------
GO
select rf_idCase, cast(id as varchar(36)) as id, GUID_MU, rf_idMO, rf_idDepartmentMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, 
		DiagnosisCode, cast(MUCode as varchar(20)) as MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments,  MUSurgery, 
		cast(rf_idSubMO as varchar(8)) as rf_idSubMO, cast(rf_idDoctor as varchar(25)) as rf_idDoctor
into t_Meduslugi2 from t_Meduslugi
GO
drop table t_Meduslugi
EXEC sp_rename 'dbo.t_Meduslugi2', 't_Meduslugi';
GO
ALTER TABLE [dbo].[t_Meduslugi]  WITH NOCHECK ADD  CONSTRAINT [FK_Meduslugi_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[t_Meduslugi] NOCHECK CONSTRAINT [FK_Meduslugi_Cases]
GO
ALTER TABLE [dbo].[t_Meduslugi] ADD [CSGQuantity] as (CONVERT([decimal](6,2),case when [MUCode]='1.11.1' then datediff(day,[DateHelpBegin],[DateHelpEnd])+(1)  end,0))
GO

if(OBJECT_ID('t_BirthWeight',N'U')) is not NULL
	DROP TABLE t_BirthWeight
GO
CREATE TABLE t_BirthWeight( rf_idCase BIGINT, BirthWeight SMALLINT CONSTRAINT FK_BirthWeight_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) ON DELETE CASCADE )
GO
---------------Create indexes-----------------------------
CREATE NONCLUSTERED INDEX [IX_RecordCase_RefRegistersCase] ON [dbo].[t_RecordCase]
(
	[rf_idRegistersCase] ASC
)
INCLUDE ( 	[id],
	[ID_Patient],
	[NumberPolis],
	[rf_idF008],
	[NewBorn],
	[idRecord],
	[IsNew]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCase_ID] ON [dbo].[t_Case]
(
	[rf_idRecordCase] ASC
)
INCLUDE ( 	[id],
	[GUID_Case],
	[idRecordCase],
	[DateBegin],
	[DateEnd],
	[AmountPayment],
	[Age],
	[IsChildTariff],
	[rf_idDirectMO],
	[rf_idV006],
	[rf_idV002],
	[NumberHistoryCase],
	[IsSpecialCase],
	[rf_idV008],
	[rf_idMO],
	[rf_idV004],
	[rf_idV010],
	[rf_idV009]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_Mes_Case_Quantity] ON [dbo].[t_MES]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[MES],
	[Quantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_idCase] ON [dbo].[t_MES]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[MES],
	[Quantity],
	[Tariff]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_MES_AccountOMS] ON [dbo].[t_MES]
(
	[MES] ASC
)
INCLUDE ( 	[rf_idCase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi]
(
	[rf_idCase] ASC
)
INCLUDE ( 	[id],
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
	[Comments]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_CaseMUCodeV004] ON [dbo].[t_Meduslugi]
(
	[rf_idCase] ASC,
	[MUCode] ASC,
	[rf_idV004] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO