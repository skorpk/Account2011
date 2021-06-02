/*
Missing Index Details from SQLQuery112.sql - (local).RegisterCases (VTFOMS\skrainov (62))
The Query Processor estimates that implementing the following index could improve the query cost by 99.9953%.
*/

USE [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_CaseDefine
ON [dbo].[t_CaseDefine] ([rf_idRefCaseIteration])
INCLUDE ([idStep])
GO
