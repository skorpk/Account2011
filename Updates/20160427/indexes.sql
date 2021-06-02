/*
Missing Index Details from SQLQuery79.sql - tserver.WCF_DB (VTFOMS\skrainov (82))
The Query Processor estimates that implementing the following index could improve the query cost by 97.8917%.
*/

USE [WCF_DB]
GO
CREATE NONCLUSTERED INDEX IX_MUCode_Case
ON [dbo].[t_Meduslugi] ([MUUnGroupCode],[MUGroupCode])
INCLUDE ([rf_idCase])
GO

USE [WCF_DB]
GO
CREATE NONCLUSTERED INDEX IX_PID_Period
ON [dbo].[t_CaseMU] ([PID],[DateBegin],[DateEnd])

GO
CREATE NONCLUSTERED INDEX IX_Case_MUCode
ON [dbo].[t_Meduslugi] ([rf_idCase])
INCLUDE ([MUUnGroupCode],[MUGroupCode],[MUCode],[rf_idV002],[DateHelpBegin],[DateHelpEnd])
GO