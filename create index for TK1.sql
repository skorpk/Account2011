/*
Missing Index Details from 20120220_1.SQLPlan
The Query Processor estimates that implementing the following index could improve the query cost by 12.3217%.
*/

USE [RegisterCases]
GO
CREATE NONCLUSTERED INDEX IX_RecordCase_RefRegistersCase
ON [dbo].[t_RecordCase] ([rf_idRegistersCase])
INCLUDE ([id]) with drop_existing
GO
create nonclustered index IX_Meduslugi_idCase_GUIDMU 
on dbo.t_Meduslugi(rf_idCase,Guid_MU,id) with drop_existing
go
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCase_ID] ON [dbo].[t_Case] 
(
	[rf_idRecordCase] ASC
)
INCLUDE ( [id],GUID_Case, idRecordCase) with drop_existing
go
CREATE NONCLUSTERED INDEX [IX_RecordCase_RefRegistersCase] ON [dbo].[t_RecordCase] 
(
	[rf_idRegistersCase] ASC
)
INCLUDE ( [id],ID_Patient) with drop_existing
go
CREATE NONCLUSTERED INDEX IX_PatientSMO_idRecordCase
ON [dbo].[t_PatientSMO] ([ref_idRecordCase])
INCLUDE ([rf_idSMO],[OKATO]) with drop_existing
GO