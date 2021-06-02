USE [RegisterCases]
GO

DROP INDEX [IX_UNumberPolicy_Ref_PID] ON [dbo].[t_CaseDefine]
GO
/****** Object:  Index [IX_UNumberPolicy_Ref_PID]    Script Date: 01/30/2014 11:37:12 ******/
CREATE NONCLUSTERED INDEX [IX_UNumberPolicy_Ref_PID] ON [dbo].[t_CaseDefine] 
(
	[UNumberPolicy] ASC
)
INCLUDE ( [rf_idRefCaseIteration],
[PID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
DROP INDEX [IX_DIO_DR] ON [dbo].[t_RegisterPatient]
GO
CREATE NONCLUSTERED INDEX [IX_DIO_DR] ON [dbo].[t_RegisterPatient] 
(
	[Fam] ASC,
	[Im] ASC,
	[Ot] ASC,
	[BirthDay] ASC
)
INCLUDE ( [id],
[rf_idFiles],
[ID_Patient],
[rf_idV005],
[BirthPlace],
[rf_idRecordCase]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCasesInsurer]
GO
/****** Object:  Index [IX_RegisterPatient_RefFile_IdPatient]    Script Date: 01/30/2014 11:47:26 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_RegisterPatient]') AND name = N'IX_RegisterPatient_RefFile_IdPatient')
DROP INDEX [IX_RegisterPatient_RefFile_IdPatient] ON [dbo].[t_RegisterPatient] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [IX_RegisterPatient_RefFile_IdPatient]    Script Date: 01/30/2014 11:47:26 ******/
CREATE NONCLUSTERED INDEX [IX_RegisterPatient_RefFile_IdPatient] ON [dbo].[t_RegisterPatient] 
(
	[rf_idFiles] ASC
)
INCLUDE ( [ID_Patient]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCasesInsurer]
GO
/****** Object:  Index [IX_UNumberPolicy_Ref]    Script Date: 01/30/2014 12:03:36 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_CaseDefineZP1Found]') AND name = N'IX_UNumberPolicy_Ref')
DROP INDEX [IX_UNumberPolicy_Ref] ON [dbo].[t_CaseDefineZP1Found] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [IX_UNumberPolicy_Ref]    Script Date: 01/30/2014 12:03:36 ******/
CREATE NONCLUSTERED INDEX [IX_UNumberPolicy_Ref] ON [dbo].[t_CaseDefineZP1Found] 
(
	[UniqueNumberPolicy] ASC
)
INCLUDE ( [rf_idRefCaseIteration]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReportYear]    Script Date: 01/30/2014 12:08:14 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[t_RegisterCaseBack]') AND name = N'IX_ReportYear')
DROP INDEX [IX_ReportYear] ON [dbo].[t_RegisterCaseBack] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_ReportYear]    Script Date: 01/30/2014 12:08:14 ******/
CREATE NONCLUSTERED INDEX [IX_ReportYear] ON [dbo].[t_RegisterCaseBack] 
(
	[ReportYear] ASC,
	[rf_idFilesBack] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCasesBack]
GO




