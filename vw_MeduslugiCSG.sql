USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_MeduslugiCSG]'))
DROP VIEW dbo.vw_MeduslugiCSG
GO
CREATE VIEW vw_MeduslugiCSG
AS
SELECT rf_idCase,DiagnosisCode,rf_idV002,rf_idV004,1 AS CSGType FROM dbo.t_Meduslugi WHERE MUCode='1.11.1'
UNION ALL 
SELECT rf_idCase,DiagnosisCode,m.rf_idV002,m.rf_idV004,2 
FROM t_Case c INNER join dbo.t_Meduslugi m ON
		c.id=m.rf_idCase
			  INNER JOIN dbo.vw_sprCSGSurgery csg ON
		m.MUCode=csg.CodeMU
WHERE c.rf_idV010=16

GO