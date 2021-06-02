/*
Missing Index Details from SQLQuery11.sql - tserver.RegisterCases (VTFOMS\SKrainov (61))
The Query Processor estimates that implementing the following index could improve the query cost by 14.6685%.
*/


USE [oms_NSI]
GO
CREATE NONCLUSTERED INDEX IX_Plan_Quarter_Flag
ON [dbo].[tPlan] ([rf_QuarterId],[flag])
INCLUDE ([rf_PlanYearId],[rf_PlanUnitId],[rate])
GO
USE [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_FileBack_DateCreate
ON [dbo].[t_FileBack] ([DateCreate])
INCLUDE ([id],[CodeM])
GO
CREATE NONCLUSTERED INDEX IX_RegisterCaseBack_ReportYear
ON [dbo].[t_RegisterCaseBack] ([ReportYear])
INCLUDE ([rf_idFilesBack])
GO
CREATE NONCLUSTERED INDEX IX_Case_ID_DateEnd
ON [dbo].[t_Case] (DateEnd,id)
GO
CREATE NONCLUSTERED INDEX [IX_Meduslugi_DateHelpEnd] ON [dbo].[t_Meduslugi] 
(
	DateHelpEnd ASC
)
INCLUDE ( [DateHelpBegin],[rf_idCase],[IsChildTariff],[MUCode],[Quantity]) 
GO
CREATE NONCLUSTERED INDEX IX_PatientBack_SMO
ON [dbo].[t_PatientBack] ([rf_idSMO])
INCLUDE ([rf_idRecordCaseBack])
GO