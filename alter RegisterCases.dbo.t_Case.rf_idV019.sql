USE RegisterCases
GO

DROP INDEX [IX_Case_idRecordCase_ID] ON [dbo].[t_Case]
GO
ALTER TABLE dbo.t_Case ALTER COLUMN rf_idV019 INT NULL
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
	[rf_idV009],
	[rf_idV018],
	[HopitalisationType],
	[rf_idV012],
	[rf_idV014],
	[rf_idV019],
	[Comments],
	[TypeTranslation],
	[rf_idDepartmentMO]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = on, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO

