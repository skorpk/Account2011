USE AccountOMSReports
GO
------------Add a new indexes----------------------------
--ALTER TABLE dbo.t_Case ADD rf_idV014 TINYINT NULL;
--ALTER TABLE dbo.t_RecordCasePatient ADD BirthWeight SMALLINT NULL;
--ALTER TABLE dbo.t_Case ADD rf_idV018 VARCHAR(19) NULL;
--ALTER TABLE dbo.t_Case ADD rf_idV019 smallint NULL;
--GO
-----------All indexes deleted-------------------
DROP INDEX [IX_Case_CodeM_ExchangeFinancing] ON [dbo].[t_Case] 
DROP INDEX [IX_Case_FinancingTestData_2] ON [dbo].[t_Case] WITH ( ONLINE = OFF )
DROP INDEX [IX_Case_idRecordCasePatient] ON [dbo].[t_Case] WITH ( ONLINE = OFF )
DROP INDEX [IX_CodeM_ExchangeFinancing_1] ON [dbo].[t_Case] WITH ( ONLINE = OFF )
DROP INDEX [IX_DateEnd_GUID_Case] ON [dbo].[t_Case] WITH ( ONLINE = OFF )
DROP INDEX [IX_EChnageFinancing_AmountPayment_1] ON [dbo].[t_Case] WITH ( ONLINE = OFF )
DROP INDEX [IX_EF_GUID_MO_DateEnd] ON [dbo].[t_Case] WITH ( ONLINE = OFF )
DROP INDEX [IX_SelectCase] ON [dbo].[t_Case] WITH ( ONLINE = OFF )

--DROP INDEX [IX_Case_FinancingTestData] ON [dbo].[t_Case] WITH ( ONLINE = OFF )

DROP INDEX [IX_MES_CASE] ON [dbo].[t_MES] WITH ( ONLINE = OFF )
DROP INDEX [IX_ClusteredIdex] ON [dbo].[t_Meduslugi] WITH ( ONLINE = OFF )
--DROP INDEX [IDX_MU_1] ON [dbo].[t_Meduslugi] WITH ( ONLINE = OFF )

--DROP INDEX [IX_RecordCasePatient_RefAccount] ON [dbo].[t_RecordCasePatient] WITH ( ONLINE = OFF )
GO
------------------------------------------------------------------																		   
ALTER TABLE dbo.t_RecordCasePatient ALTER COLUMN idRecord INT 
GO
------------------------------------------------------------------
ALTER TABLE dbo.t_Case ALTER COLUMN	idRecordCase BIGINT NOT NULL;
GO
ALTER TABLE dbo.t_Case DROP COLUMN rf_idSubMO
ALTER TABLE dbo.t_Case ADD rf_idSubMO VARCHAR(8) NULL;
GO
ALTER TABLE dbo.t_Case DROP COLUMN rf_idDoctor
ALTER TABLE dbo.t_Case ADD rf_idDoctor VARCHAR(25) NULL;
--------------------------------------------------------------------
ALTER TABLE dbo.t_MES ALTER COLUMN MES varchar(20) NULL;
-------t_Meduslugi------------------------------------------------------------
ALTER TABLE dbo.t_Meduslugi ALTER COLUMN id VARCHAR(36) NOT NULL


-----------------------------------------------------
GO
USE AccountOMS
if(OBJECT_ID('t_BirthWeight',N'U')) is not NULL
	DROP TABLE t_BirthWeight
GO
CREATE TABLE t_BirthWeight( rf_idCase BIGINT, BirthWeight SMALLINT CONSTRAINT FK_BirthWeight_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id) ON DELETE CASCADE )
GO
------------Indexes----------------------------------
--CREATE NONCLUSTERED INDEX [IX_ID_rf_idRegistersAccounts] ON [dbo].[t_RecordCasePatient] 
--(
--	[id] ASC,
--	[rf_idRegistersAccounts] ASC
--)
--INCLUDE ( [SeriaPolis],
--[NumberPolis],
--[AttachLPU]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSInsurer]
--GO
--CREATE NONCLUSTERED INDEX [IX_RecordCasePatient_RefAccount] ON [dbo].[t_RecordCasePatient] 
--(
--	[rf_idRegistersAccounts] ASC
--)
--INCLUDE ( [id],
--[SeriaPolis],
--[NumberPolis],
--[AttachLPU]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountOMSInsurer]
--GO
CREATE NONCLUSTERED INDEX [IX_Case_CodeM_ExchangeFinancing] ON [dbo].[t_Case] 
(
	[rf_idMO] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[idRecordCase],
[GUID_Case],
[AmountPayment],
[DateEnd])
GO
CREATE NONCLUSTERED INDEX [IX_Case_FinancingTestData_2] ON [dbo].[t_Case] 
(
	[idRecordCase] ASC,
	[rf_idMO] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[GUID_Case],
[AmountPayment],
[DateEnd]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCasePatient] ON [dbo].[t_Case] 
(
	[rf_idRecordCasePatient] ASC,
	[id] ASC
)
INCLUDE ( [rf_idMO],
[idRecordCase],
[rf_idV006],
[rf_idV008],
[rf_idDirectMO],
[HopitalisationType],
[rf_idV002],
[IsChildTariff],
[NumberHistoryCase],
[DateBegin],
[DateEnd],
[rf_idV009],
[rf_idV012],
[rf_idV004],
[rf_idV010],
[AmountPayment],
[GUID_Case],
[Age]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_CodeM_ExchangeFinancing_1] ON [dbo].[t_Case] 
(
	[rf_idMO] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[GUID_Case],
[AmountPayment],
[idRecordCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_DateEnd_GUID_Case] ON [dbo].[t_Case] 
(
	[DateEnd] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[GUID_Case],
[idRecordCase],
[rf_idMO],
[rf_idSubMO],
[rf_idDepartmentMO],
[rf_idV002],
[IsChildTariff],
[DateBegin],
[rf_idV004],
[rf_idDoctor],
[Age],
[AmountPayment],
[rf_idV006]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_EChnageFinancing_AmountPayment_1] ON [dbo].[t_Case] 
(
	[rf_idMO] ASC,
	[AmountPayment] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[idRecordCase],
[DateEnd]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_EF_GUID_MO_DateEnd] ON [dbo].[t_Case] 
(
	[GUID_Case] ASC,
	[rf_idMO] ASC,
	[DateEnd] ASC
)
INCLUDE ( [rf_idRecordCasePatient],
[idRecordCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_SelectCase] ON [dbo].[t_Case] 
(
	[DateEnd] ASC
)
INCLUDE ( [id],
[rf_idRecordCasePatient],
[idRecordCase],
[rf_idV006],
[rf_idV008],
[rf_idDirectMO],
[HopitalisationType],
[rf_idV002],
[IsChildTariff],
[NumberHistoryCase],
[DateBegin],
[rf_idV009],
[rf_idV012],
[rf_idV004],
[rf_idV010],
[AmountPayment],
[Age]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE NONCLUSTERED INDEX [IX_MES_CASE] ON [dbo].[t_MES] 
(
	[rf_idCase] ASC
)
INCLUDE ( [MES],
[Quantity],
[Tariff]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
GO
CREATE CLUSTERED INDEX [IX_ClusteredIdex] ON [dbo].[t_Meduslugi] 
(
	[id] ASC,
	[rf_idCase] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE=OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountMU]
GO
--CREATE NONCLUSTERED INDEX [IDX_MU_1] ON [dbo].[t_Meduslugi] 
--(
--	[rf_idCase] ASC
--)
--INCLUDE ( [rf_idV002],
--[DateHelpBegin],
--[DateHelpEnd],
--[Quantity],
--[Price],
--[TotalPrice],
--[rf_idV004],
--[rf_idDoctor],
--[MU],
--[MUSurgery]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [AccountMU]
--GO

