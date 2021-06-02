/*
Missing Index Details from query's test for usp_FillBackTablesAfterAllIteration.sql - tserver.RegisterCases (VTFOMS\SKrainov (72))
The Query Processor estimates that implementing the following index could improve the query cost by 78.7637%.
*/

USE [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_PatientSMO_OKATO
ON [dbo].[t_PatientSMO] ([OKATO])
INCLUDE ([ref_idRecordCase]) WHERE OKATO IS NOT NULL
GO
CREATE NONCLUSTERED INDEX IX_CaseDefineZP1Found_Ref_OGRN_SMO
ON [dbo].[t_CaseDefineZP1Found] ([rf_idRefCaseIteration],[OGRN_SMO],[NPolcy])
GO
CREATE NONCLUSTERED INDEX IX_RefCasePatientDefine_idFiles_IsUnloadIntoSP_TK
ON [dbo].[t_RefCasePatientDefine] ([rf_idFiles],[IsUnloadIntoSP_TK])
INCLUDE ([id],[rf_idCase],[rf_idRegisterPatient])
GO