use [RegisterCases]
go

CREATE NONCLUSTERED INDEX [_dta_index_t_FileBack_30_1074102867__K2_K1_3_5_7] ON [dbo].[t_FileBack] 
(
	[rf_idFiles] ASC,
	[id] ASC
)
INCLUDE ( [DateCreate],
[FileNameHRBack],
[IsUnload]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_1074102867_1_2] ON [dbo].[t_FileBack]([id], [rf_idFiles])
go

CREATE NONCLUSTERED INDEX [_dta_index_t_RegisterCaseBack_30_1202103323__K2_K7_K8_K4_K5] ON [dbo].[t_RegisterCaseBack] 
(
	[rf_idFilesBack] ASC,
	[NumberRegister] ASC,
	[PropertyNumberRegister] ASC,
	[ReportYear] ASC,
	[ReportMonth] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
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

CREATE STATISTICS [_dta_stat_405576483_2_11] ON [dbo].[t_File]([id], [CodeM])
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

CREATE STATISTICS [_dta_stat_405576483_3_11_2] ON [dbo].[t_File]([DateRegistration], [CodeM], [id])
go

