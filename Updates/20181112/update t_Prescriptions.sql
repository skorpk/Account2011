USE RegisterCases
GO
ALTER TABLE dbo.t_Prescriptions ADD DirectionDate DATE 
GO
ALTER TABLE dbo.t_Prescriptions ADD DirectionMU VARCHAR(15)
GO
ALTER TABLE dbo.t_Prescriptions ADD DirectionMO VARCHAR(6)
GO
USE AccountOMS
GO
ALTER TABLE dbo.t_Prescriptions ADD DirectionDate DATE 
GO
ALTER TABLE dbo.t_Prescriptions ADD DirectionMU VARCHAR(15)
GO
ALTER TABLE dbo.t_Prescriptions ADD DirectionMO VARCHAR(6)
go