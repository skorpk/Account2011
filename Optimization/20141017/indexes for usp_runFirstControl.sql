USE [RegisterCases]
GO

CREATE NONCLUSTERED INDEX [IX_GUID_ID] ON [dbo].[t_Case] 
(
	[GUID_Case] ASC
)
INCLUDE ( [id],rf_idRecordCase) WITH (DROP_EXISTING = ON,ONLINE=ON) ON [RegisterCases]
GO
-----------------------------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCase_ID] ON [dbo].[t_Case] 
(
	[rf_idRecordCase] ASC
)
INCLUDE ( [id],[GUID_Case],[idRecordCase],[DateBegin],[DateEnd],[AmountPayment],[Age],[IsChildTariff],[rf_idDirectMO],[rf_idV006],[rf_idV002],
		[NumberHistoryCase],[IsSpecialCase],[rf_idV008],[rf_idMO],[rf_idV004],[rf_idV010],[rf_idV009],[rf_idV018],[HopitalisationType],[rf_idV012],
		[rf_idV014],[rf_idV019],Comments) 
WITH (DROP_EXISTING = ON,ONLINE=ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_RecordCase_RefRegistersCase] ON [dbo].[t_RecordCase] 
(
	[rf_idRegistersCase] ASC
)
INCLUDE ( [id],[ID_Patient],[NumberPolis],[rf_idF008],[NewBorn],[idRecord],[IsNew],BirthWeight) 
WITH (DROP_EXISTING = ON,ONLINE=ON) ON [PRIMARY]
GO



