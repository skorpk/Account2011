USE RegisterCases
GO
ALTER TABLE dbo.t_RegisterPatientDocument ADD DOCDATE DATE 
GO
ALTER TABLE dbo.t_RegisterPatientDocument ADD DOCORG VARCHAR(1000)
GO
USE AccountOMS
go
ALTER TABLE dbo.t_RegisterPatientDocument ADD DOCDATE DATE 
GO
ALTER TABLE dbo.t_RegisterPatientDocument ADD DOCORG VARCHAR(1000)