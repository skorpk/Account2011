USE RegisterCases
go
IF OBJECT_ID('vw_sprMuPRVSAge',N'V') IS NOT NULL
DROP VIEW vw_sprMuPRVSAge
GO
CREATE VIEW vw_sprMuPRVSAge
AS
select MUCode,MedSpecCode as rf_idV004,case when AgeGroup=2 then 1 else 0 end as IsChildTariff 
from OMS_NSI.dbo.V_MUMedicalSpeciality
go