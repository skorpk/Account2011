USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprDentalMUProfilConditionPRVS]    Script Date: 17.01.2019 8:23:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW dbo.vw_sprDentalMUProfilConditionPRVS
as
SELECT m.code AS MUCode,
       v021.IDSPEC AS rf_idV015,
          ss.code AS rf_idV002, 
          c.code AS rf_idV006
FROM OMS_NSI.dbo.sprDentalMU m 
     INNER JOIN oms_nsi.dbo.sprDentalMUV021 s ON m.DentalMUId=s.rf_DentalMUId
     INNER JOIN OMS_NSI.dbo.sprDentalMUProfile p ON m.DentalMUId=p.rf_DentalMUId 
     INNER JOIN oms_nsi.dbo.tMedicalService ss ON p.rf_MedicalServiceId=ss.MedicalServiceId 
     INNER JOIN OMS_NSI.dbo.sprV021 v021 ON s.rf_sprV021Id=v021.SprV021Id                       
     INNER JOIN OMS_NSI.dbo.tMSCondition c ON m.rf_MSConditionId=c.MSConditionId

GO


