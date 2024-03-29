use [AccountOMS]
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE NONCLUSTERED INDEX [_dta_index_t_File_31_293576084__K2_K9_3_6] ON [dbo].[t_File] 
(
	[id] ASC,
	[CodeM] ASC
)
INCLUDE ( [DateRegistration],
[FileNameHR]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_293576084_9_3] ON [dbo].[t_File]([CodeM], [DateRegistration])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_293576084_10_9_2] ON [dbo].[t_File]([Insurance], [CodeM], [id])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegistersAccounts_31_677577452__K5_K8_K1_6_10_12_20] ON [dbo].[t_RegistersAccounts] 
(
	[ReportYear] ASC,
	[PrefixNumberRegister] ASC,
	[rf_idFiles] ASC
)
INCLUDE ( [ReportMonth],
[DateRegister],
[AmountPayment],
[Account]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegistersAccounts_31_677577452__K1_K8_K2_5_6_7_9_10_12_19] ON [dbo].[t_RegistersAccounts] 
(
	[rf_idFiles] ASC,
	[PrefixNumberRegister] ASC,
	[id] ASC
)
INCLUDE ( [ReportYear],
[ReportMonth],
[NumberRegister],
[PropertyNumberRegister],
[DateRegister],
[AmountPayment],
[Letter]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegistersAccounts_31_677577452__K3_K1] ON [dbo].[t_RegistersAccounts] 
(
	[idRecord] ASC,
	[rf_idFiles] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_677577452_5_20] ON [dbo].[t_RegistersAccounts]([ReportYear], [Account])
go

CREATE STATISTICS [_dta_stat_677577452_1_3] ON [dbo].[t_RegistersAccounts]([rf_idFiles], [idRecord])
go

CREATE STATISTICS [_dta_stat_677577452_2_1] ON [dbo].[t_RegistersAccounts]([id], [rf_idFiles])
go

CREATE STATISTICS [_dta_stat_677577452_11_1] ON [dbo].[t_RegistersAccounts]([rf_idSMO], [rf_idFiles])
go

CREATE STATISTICS [_dta_stat_677577452_1_6] ON [dbo].[t_RegistersAccounts]([rf_idFiles], [ReportMonth])
go

CREATE STATISTICS [_dta_stat_677577452_8_5_1] ON [dbo].[t_RegistersAccounts]([PrefixNumberRegister], [ReportYear], [rf_idFiles])
go

CREATE STATISTICS [_dta_stat_677577452_6_7_1] ON [dbo].[t_RegistersAccounts]([ReportMonth], [NumberRegister], [rf_idFiles])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_677577452_5_1_20] ON [dbo].[t_RegistersAccounts]([ReportYear], [rf_idFiles], [Account])
go

CREATE STATISTICS [_dta_stat_677577452_2_11_1] ON [dbo].[t_RegistersAccounts]([id], [rf_idSMO], [rf_idFiles])
go

CREATE STATISTICS [_dta_stat_789577851_2_1] ON [dbo].[t_RegisterPatientDocument]([rf_idDocumentType], [rf_idRegisterPatient])
go

CREATE STATISTICS [_dta_stat_917578307_1_18] ON [dbo].[t_Case]([id], [rf_idV012])
go

CREATE STATISTICS [_dta_stat_917578307_1_17_19] ON [dbo].[t_Case]([id], [rf_idV009], [rf_idV004])
go

CREATE STATISTICS [_dta_stat_917578307_1_7_19_18] ON [dbo].[t_Case]([id], [rf_idDirectMO], [rf_idV004], [rf_idV012])
go

CREATE STATISTICS [_dta_stat_917578307_1_12_19_18_17] ON [dbo].[t_Case]([id], [rf_idV002], [rf_idV004], [rf_idV012], [rf_idV009])
go

CREATE STATISTICS [_dta_stat_917578307_1_19_18_17_7_12] ON [dbo].[t_Case]([id], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002])
go

CREATE STATISTICS [_dta_stat_917578307_1_5_19_18_17_7_12] ON [dbo].[t_Case]([id], [rf_idV006], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002])
go

CREATE STATISTICS [_dta_stat_917578307_6_1_19_18_17_7_12_22] ON [dbo].[t_Case]([rf_idV008], [id], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV010])
go

CREATE STATISTICS [_dta_stat_917578307_1_2_19_18_17_7_12_22_5] ON [dbo].[t_Case]([id], [rf_idRecordCasePatient], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV010], [rf_idV006])
go

CREATE STATISTICS [_dta_stat_917578307_19_18_17_7_12_22_5_6_2] ON [dbo].[t_Case]([rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV010], [rf_idV006], [rf_idV008], [rf_idRecordCasePatient])
go

CREATE STATISTICS [_dta_stat_917578307_22_1_19_18_17_7_12_5_6_2] ON [dbo].[t_Case]([rf_idV010], [id], [rf_idV004], [rf_idV012], [rf_idV009], [rf_idDirectMO], [rf_idV002], [rf_idV006], [rf_idV008], [rf_idRecordCasePatient])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_1045578763_21_22] ON [dbo].[t_Meduslugi]([MU], [MUSurgery])
go

CREATE STATISTICS [_dta_stat_1045578763_1_16_22] ON [dbo].[t_Meduslugi]([rf_idCase], [Price], [MUSurgery])
go

SET QUOTED_IDENTIFIER ON
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

SET ARITHABORT ON
go

SET CONCAT_NULL_YIELDS_NULL ON
go

SET QUOTED_IDENTIFIER ON
go

SET ANSI_NULLS ON
go

SET ANSI_PADDING ON
go

SET ANSI_WARNINGS ON
go

SET NUMERIC_ROUNDABORT OFF
go

CREATE STATISTICS [_dta_stat_1045578763_22_1_21_16] ON [dbo].[t_Meduslugi]([MUSurgery], [rf_idCase], [MU], [Price])
go

CREATE STATISTICS [_dta_stat_1061578820_2_5] ON [dbo].[t_MES]([rf_idCase], [Tariff])
go

CREATE STATISTICS [_dta_stat_1061578820_1_2_5] ON [dbo].[t_MES]([MES], [rf_idCase], [Tariff])
go

CREATE STATISTICS [_dta_stat_613577224_1_10] ON [dbo].[t_RegisterPatient]([id], [rf_idRecordCase])
go

CREATE STATISTICS [_dta_stat_613577224_7_1_10] ON [dbo].[t_RegisterPatient]([rf_idV005], [id], [rf_idRecordCase])
go

