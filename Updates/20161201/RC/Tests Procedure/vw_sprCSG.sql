USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprCSG]    Script Date: 26.01.2017 14:49:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_sprCSG]
AS
SELECT tCSG.CSGroupId, tCSG.code, tCSG.name,tCSG.rf_CSGTypeId,t1.NAME AS TypeName,noKSLP, tCSG.dateBeg,tCSG.dateEnd
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGType t1 ON
				tCSG.rf_CSGTypeId=t1.CSGTypeId

GO


