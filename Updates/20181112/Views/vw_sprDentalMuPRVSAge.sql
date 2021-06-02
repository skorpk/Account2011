USE [oms_nsi]
GO

/****** Object:  View [dbo].[vw_sprDentalMuPRVSAge]    Script Date: 15.01.2019 16:01:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vw_sprDentalMuPRVSAge]
as
--SELECT s.DentalMUId,s.code,sd.rf_AgeGroupId-1 AS rf_AgeGroupId, sd.rf_sprV015RecId
--FROM dbo.sprDentalMU s INNER JOIN dbo.sprDentalMUDocSpec sd ON
--			s.DentalMUId=sd.rf_DentalMUId
SELECT s.DentalMUId,s.code,sd.rf_AgeGroupId-1 AS rf_AgeGroupId, v21.IDSPEC AS rf_sprV015RecId
FROM dbo.sprDentalMU s 
     INNER JOIN dbo.sprDentalMUV021 sd ON s.DentalMUId=sd.rf_DentalMUId
			INNER JOIN oms_nsi.dbo.sprV021 v21 ON
	sd.rf_sprV021Id=v21.SprV021Id          


GO


