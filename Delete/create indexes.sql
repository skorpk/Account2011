USE [RegisterCasesTest]
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
	[Comments],
	[MUSurgery],
	[rf_idDoctor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_CaseMUCodeV004] ON [dbo].[t_Meduslugi]
(
	[rf_idCase] ASC,
	[MUCode] ASC,
	[rf_idV004] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCases]
GO



