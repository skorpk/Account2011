USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprCSG]'))
DROP VIEW dbo.vw_sprCSG
GO
CREATE VIEW vw_sprCSG
AS
SELECT tCSG.CSGroupId, tCSG.code, tCSG.name,tCSG.rf_CSGTypeId,t1.NAME AS TypeName
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGType t1 ON
				tCSG.rf_CSGTypeId=t1.CSGTypeId
GO							
