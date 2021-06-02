USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprMUCompletedCase]    Script Date: 06/18/2013 15:43:39 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprCSGTherapyMKB]'))
DROP VIEW dbo.vw_sprCSGTherapyMKB
GO
CREATE VIEW vw_sprCSGTherapyMKB
AS
SELECT tCSG.CSGroupId, tCSG.code, tCSG.name,mkb.MKBCode
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGMKB mkb ON
				tCSG.CSGroupId=mkb.rf_CSGroupId
WHERE rf_CSGTypeId=1--עונאן.Êֳׁ
GO