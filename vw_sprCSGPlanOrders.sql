USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprCSGPlanOrders]'))
DROP VIEW dbo.vw_sprCSGPlanOrders
GO
CREATE VIEW vw_sprCSGPlanOrders
AS
SELECT tCSG.CSGroupId, tCSG.code, tCSG.name,tCSG.rf_CSGTypeId,t1.NAME AS TypeName
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGType t1 ON
				tCSG.rf_CSGTypeId=t1.CSGTypeId
GO							
