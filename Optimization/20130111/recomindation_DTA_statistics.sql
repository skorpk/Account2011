use [RegisterCases]
go
-----------------------------------[t_PatientBack]-------------------------------------------------
CREATE STATISTICS [_dta_stat_1892201791_2_3_4_5_6] ON [dbo].[t_PatientBack]([rf_idF008], [SeriaPolis], [NumberPolis], [rf_idSMO], [OKATO])
go
-----------------------------------t_ErrorProcessControl-------------------------------------------
CREATE STATISTICS [_dta_stat_133575514_4_2] ON [dbo].[t_ErrorProcessControl]([rf_idCase], [ErrorNumber])
go

CREATE STATISTICS [_dta_stat_133575514_1_2_4_5] ON [dbo].[t_ErrorProcessControl]([DateRegistration], [ErrorNumber], [rf_idCase], [GUID_MU])
go

CREATE STATISTICS [_dta_stat_133575514_4_3_2_1_5] ON [dbo].[t_ErrorProcessControl]([rf_idCase], [rf_idFile], [ErrorNumber], [DateRegistration], [GUID_MU])
go
----------------------------------t_RegisterCaseBack--------------------------------------------------
CREATE STATISTICS [_dta_stat_1202103323_7_1] ON [dbo].[t_RegisterCaseBack]([NumberRegister], [id])
go

CREATE STATISTICS [_dta_stat_1202103323_2_1_5] ON [dbo].[t_RegisterCaseBack]([rf_idFilesBack], [id], [ReportMonth])
go

CREATE STATISTICS [_dta_stat_1202103323_7_8_4] ON [dbo].[t_RegisterCaseBack]([NumberRegister], [PropertyNumberRegister], [ReportYear])
go

CREATE STATISTICS [_dta_stat_1202103323_1_4_5_2] ON [dbo].[t_RegisterCaseBack]([id], [ReportYear], [ReportMonth], [rf_idFilesBack])
go

CREATE STATISTICS [_dta_stat_1202103323_7_2_8_4_5] ON [dbo].[t_RegisterCaseBack]([NumberRegister], [rf_idFilesBack], [PropertyNumberRegister], [ReportYear], [ReportMonth])
go

CREATE STATISTICS [_dta_stat_1202103323_2_7_1_8_4_5] ON [dbo].[t_RegisterCaseBack]([rf_idFilesBack], [NumberRegister], [id], [PropertyNumberRegister], [ReportYear], [ReportMonth])
go
------------------------------------t_PlanOrders2011----------------------------------------------
CREATE STATISTICS [_dta_stat_53575229_4_3] ON [dbo].[t_PlanOrders2011]([unitCode], [YearRate])
go

CREATE STATISTICS [_dta_stat_53575229_1_4] ON [dbo].[t_PlanOrders2011]([CodeLPU], [unitCode])
go
-------------------------------------[t_RecordCaseBack]---------------------------------------------
CREATE STATISTICS [_dta_stat_1282103608_2_4] ON [dbo].[t_RecordCaseBack]([rf_idRegisterCaseBack], [rf_idCase])
go

CREATE STATISTICS [_dta_stat_1282103608_3_2_4] ON [dbo].[t_RecordCaseBack]([rf_idRecordCase], [rf_idRegisterCaseBack], [rf_idCase])
go
-------------------------------------[t_RecordCase]----------------------------------------------
CREATE STATISTICS [_dta_stat_1045578763_3_1] ON [dbo].[t_RecordCase]([idRecord], [id])
go

CREATE STATISTICS [_dta_stat_1045578763_3_5] ON [dbo].[t_RecordCase]([idRecord], [ID_Patient])
go

CREATE STATISTICS [_dta_stat_1045578763_1_3_5] ON [dbo].[t_RecordCase]([id], [idRecord], [ID_Patient])
go
------------------------------------t_FileBack--------------------------------------------------
CREATE STATISTICS [_dta_stat_1074102867_9_1] ON [dbo].[t_FileBack]([CodeM], [id])
go

CREATE STATISTICS [_dta_stat_1074102867_2_1] ON [dbo].[t_FileBack]([rf_idFiles], [id])
go

CREATE STATISTICS [_dta_stat_1074102867_1_7] ON [dbo].[t_FileBack]([id], [IsUnload])
go

CREATE STATISTICS [_dta_stat_1074102867_10_1_2] ON [dbo].[t_FileBack]([MM], [id], [rf_idFiles])
go
----------------------------------[t_RegistersCase]--------------------------------------------
CREATE STATISTICS [_dta_stat_933578364_1_2] ON [dbo].[t_RegistersCase]([rf_idFiles], [id])
go

CREATE STATISTICS [_dta_stat_933578364_6_1] ON [dbo].[t_RegistersCase]([NumberRegister], [rf_idFiles])
go
--------------------------------------[t_RefCasePatientDefine]---------------------------------
CREATE STATISTICS [_dta_stat_130099504_5_2] ON [dbo].[t_RefCasePatientDefine]([IsUnloadIntoSP_TK], [rf_idCase])
go

CREATE STATISTICS [_dta_stat_130099504_4_1] ON [dbo].[t_RefCasePatientDefine]([rf_idFiles], [id])
go
--------------------------------------[t_File]------------------------------------------
CREATE STATISTICS [_dta_stat_405576483_9_2] ON [dbo].[t_File]([rf_idFileTested], [id])
go

CREATE STATISTICS [_dta_stat_405576483_3_11] ON [dbo].[t_File]([DateRegistration], [CodeM])
go

CREATE STATISTICS [_dta_stat_405576483_5_2] ON [dbo].[t_File]([DateCreate], [id])
go

CREATE STATISTICS [_dta_stat_405576483_9_11_2] ON [dbo].[t_File]([rf_idFileTested], [CodeM], [id])
go

CREATE STATISTICS [_dta_stat_405576483_2_11_3] ON [dbo].[t_File]([id], [CodeM], [DateRegistration])
go
---------------------------------------[t_Case]---------------------------------------------
CREATE STATISTICS [_dta_stat_674101442_9_13] ON [dbo].[t_Case]([rf_idMO], [IsChildTariff])
go

CREATE STATISTICS [_dta_stat_674101442_1_13] ON [dbo].[t_Case]([id], [IsChildTariff])
go

CREATE STATISTICS [_dta_stat_674101442_3_4] ON [dbo].[t_Case]([idRecordCase], [GUID_Case])
go

CREATE STATISTICS [_dta_stat_674101442_9_1_13] ON [dbo].[t_Case]([rf_idMO], [id], [IsChildTariff])
go

CREATE STATISTICS [_dta_stat_674101442_1_3_4] ON [dbo].[t_Case]([id], [idRecordCase], [GUID_Case])
go
--------------------------------------[t_Meduslugi]------------------------------------------------
CREATE STATISTICS [_dta_stat_898102240_1_12_8] ON [dbo].[t_Meduslugi]([rf_idCase], [MUCode], [IsChildTariff])
go

