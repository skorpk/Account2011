USE PolicyRegister
go
CREATE NONCLUSTERED INDEX IX_PEOPLE_VIEW
ON [dbo].[PEOPLE] ([ID])
INCLUDE ([ENP],[RN]) 
GO
USE [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_POLIS_1
ON [dbo].[POLIS] ([PID],[DBEG],[DEND],[Q])
INCLUDE ([SPOL],[NPOL],[POLTP]) on [RegisterCasesInsurer]
GO
CREATE NONCLUSTERED INDEX IX_PlanOrder
ON [dbo].[t_PlanOrders2011] ([CodeLPU],[MonthRate])
INCLUDE ([unitCode],[Rate]) 
GO
CREATE NONCLUSTERED INDEX IX_RegisterPatientDocument
ON [dbo].[t_RegisterPatientDocument] ([rf_idRegisterPatient])
INCLUDE ([NumberDocument],[SNILS])
GO
CREATE NONCLUSTERED INDEX IX_RecordCase_RegistersCase
ON [dbo].[t_RecordCase] ([rf_idRegistersCase])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_RefCasePatientDefine_idFile
ON [dbo].[t_RefCasePatientDefine] ([rf_idFiles])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_Case_ecordCase
ON [dbo].[t_Case] ([rf_idRecordCase])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_CaseDefine_RefCaseIteration
ON [dbo].[t_CaseDefine] ([rf_idRefCaseIteration])
GO
CREATE NONCLUSTERED INDEX IX_PatientBack_idRecordCaseBack_SMO
ON [dbo].[t_PatientBack] ([rf_idRecordCaseBack])
INCLUDE ([rf_idSMO])
GO
CREATE NONCLUSTERED INDEX IX_RecordCaseBack_RegisterCaseBack
ON [dbo].[t_RecordCaseBack] ([rf_idRegisterCaseBack])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_RefCasePatient_idCase_id
ON [dbo].[t_RefCasePatientDefine] ([rf_idCase])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_Case_MO_idRecordCase
ON [dbo].[t_Case] ([rf_idMO])
INCLUDE ([id],[rf_idRecordCase])
GO
CREATE NONCLUSTERED INDEX IX_CaseBlack_TypePay_idRecordCaseBack
ON [dbo].[t_CaseBack] ([TypePay])
INCLUDE ([rf_idRecordCaseBack])
GO
CREATE NONCLUSTERED INDEX IX_RecordCaseBack_idCase_ID
ON [dbo].[t_RecordCaseBack] ([rf_idCase])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi] 
(
	[rf_idCase] ASC
)
INCLUDE ( [DateHelpBegin],
		  [DateHelpEnd],IsChildTariff,MUCode,Quantity
		  ) WITH DROP_EXISTING  ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_CasePatientDefineIteration_Iterarion
ON [dbo].[t_CasePatientDefineIteration] ([rf_idIteration])
INCLUDE ([rf_idRefCaseIteration])
GO
CREATE NONCLUSTERED INDEX IX_CaseDefineZP1Found_OGRN_Policy
ON [dbo].[t_CaseDefineZP1Found] ([OGRN_SMO],[NPolcy])
INCLUDE ([rf_idRefCaseIteration],[OKATO],[TypePolicy],[SPolicy])
GO
CREATE NONCLUSTERED INDEX IX_XasePatientDefine
ON [dbo].[t_CasePatientDefineIteration] ([rf_idRefCaseIteration],[rf_idIteration])
GO
-----06.01.2012--------------
CREATE NONCLUSTERED INDEX IX_RegisterPatient_idRecordCase
ON [dbo].[t_RegisterPatient] ([rf_idRecordCase],[ID_Patient])
GO
CREATE NONCLUSTERED INDEX IX_RecordCase_F008_NPolisLen
ON [dbo].[t_RecordCase] ([rf_idF008],[NPolisLen])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_Case_idRecordCase
ON [dbo].[t_Case] ([rf_idRecordCase])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX IX_RecordCase_IsChild_Lenght
ON [dbo].[t_RecordCase] ([IsChild])
INCLUDE ([id],[NewBorn])
GO
CREATE NONCLUSTERED INDEX IX_RefCasePatientDefine_IsUnload
ON [dbo].[t_RefCasePatientDefine] ([IsUnloadIntoSP_TK])
INCLUDE ([id],[rf_idFiles])
GO
CREATE NONCLUSTERED INDEX IX_RegisterPatient_RefFile_IdPatient
ON [dbo].[t_RegisterPatient] ([rf_idFiles])
INCLUDE ([ID_Patient])
GO
create nonclustered index IX_RefCasePatientDefine_File on dbo.t_RefCasePatientDefine(rf_idFiles)
go
CREATE NONCLUSTERED INDEX IX_RefRegisterPatientRecordCase_idRegisterPatient
ON [dbo].[t_RefRegisterPatientRecordCase] ([rf_idRegisterPatient])
INCLUDE ([rf_idRecordCase])
GO
create unique nonclustered index QU_CaseDefineZP1Found on dbo.t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1) WITH IGNORE_DUP_KEY
go
create unique nonclustered index QU_CasePatientDefineIteration on dbo.t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration) WITH IGNORE_DUP_KEY
go
create nonclustered index IX_RecordCaseBack_All_Columns on dbo.t_RecordCaseBack
(rf_idRegisterCaseBack) INCLUDE(id,rf_idRecordCase,rf_idCase) with drop_existing
go
create nonclustered index IX_RegisterCaseBack_ReportMonthYear_id on dbo.t_RegisterCaseBack
(ReportYear,ReportMonth) include(id)
go
create nonclustered index IX_FileBackID_DateCreate on dbo.t_FileBack (id,DateCreate) with drop_existing
go
USE [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_DateCreate_ID_CodeM
ON [dbo].[t_FileBack] ([DateCreate])
INCLUDE ([id],[CodeM])
GO
CREATE NONCLUSTERED INDEX IX_ReportYear_RefFileBack
ON [dbo].[t_RegisterCaseBack] ([ReportYear])
INCLUDE ([rf_idFilesBack])
GO
CREATE NONCLUSTERED INDEX IX_IdFileBack
ON [dbo].[t_RegisterCaseBack] ([rf_idFilesBack]) 
INCLUDE(DateCreate,ReportMonth,ReportYear,NumberRegister,PropertyNumberRegister) 
go
CREATE NONCLUSTERED INDEX IX_ErrorNumber_RefCase
ON [dbo].[t_ErrorProcessControl] (rf_idFile,[ErrorNumber])
INCLUDE ([rf_idCase]) 
GO
CREATE NONCLUSTERED INDEX IX_idFileTested_FileName
ON [dbo].[t_FileError] ([rf_idFileTested])
INCLUDE ([FileNameP])
GO
CREATE NONCLUSTERED INDEX IX_RefFiles
ON [dbo].[t_RegistersCase] ([rf_idFiles])
INCLUDE (DateRegister,NumberRegister,ReportMonth,ReportYear) 
GO