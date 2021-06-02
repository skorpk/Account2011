USE [RegisterCases]
GO
/****** Object:  Index [IX_RefCasePatientDefine_File]    Script Date: 03/21/2012 10:16:31 ******/
CREATE NONCLUSTERED INDEX [IX_RefCasePatientDefine_File] ON [dbo].[t_RefCasePatientDefine] 
(
	[rf_idFiles] ASC,
	[IsUnloadIntoSP_TK] 
)
INCLUDE(rf_idCase,rf_idRegisterPatient)
WITH DROP_EXISTING ON [RegisterCasesInsurer]
GO
CREATE NONCLUSTERED INDEX IX_CaseDefineZP1Found_OurRegion ON [dbo].[t_CaseDefineZP1Found] 
(
	[rf_idRefCaseIteration] ASC
)
where OKATO='18000' ON [RegisterCasesInsurer]
GO
CREATE NONCLUSTERED INDEX IX_CaseDefineZP1Found_OtherRegion ON [dbo].[t_CaseDefineZP1Found] 
(
	[rf_idRefCaseIteration] ASC
)
where OKATO<>'18000' ON [RegisterCasesInsurer]
GO
CREATE NONCLUSTERED INDEX IX_CaseDefineZP1Found_Empty_OGRN ON [dbo].[t_CaseDefineZP1Found] 
(
	[rf_idRefCaseIteration] ASC,
	rf_idZP1
)
INCLUDE(OGRN_SMO,NPolcy) ON [RegisterCasesInsurer]
GO

CREATE NONCLUSTERED INDEX IX_CaseDefineZP1Found_NotDefine ON [dbo].[t_CaseDefineZP1Found] 
(
	[rf_idRefCaseIteration] ASC
)
where OKATO is null ON [RegisterCasesInsurer]
GO
CREATE CLUSTERED INDEX IX_ListPeopleFromPlotnikov ON [dbo].[ListPeopleFromPlotnikov] 
(
	FAM,
	IM,
	OT,
	DR
) ON [RegisterCasesInsurer]
GO
CREATE NONCLUSTERED INDEX [IX_RefFiles] ON [dbo].[t_RegistersCase] 
(
	[rf_idFiles] ASC
)
INCLUDE ( 
			[DateRegister],
			[NumberRegister],
			[ReportMonth],
			[ReportYear],
			rf_idMO
			
) WITH DROP_EXISTING  ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_RefRegisterPatient on dbo.t_RegisterPatientAttendant
(
	rf_idRegisterPatient
) ON [RegisterCasesInsurer]