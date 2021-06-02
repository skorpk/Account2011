USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprMUUnionV008]'))
DROP VIEW dbo.vw_sprMUUnionV008
GO
CREATE VIEW vw_sprMUUnionV008
AS 
select CAST(m1.MUGroupCode as varchar(2))+'.'+cast(m2.MUUnGroupCode as varchar(2))+'.'+CAST(m3.MUCode as varchar(3)) AS MU
	   ,m3.MUName		
	   ,m3.rf_sprV008Id AS V008 ,v008.Name
from OMS_NSI.dbo.sprMUGroup m1 inner join OMS_NSI.dbo.sprMUUnGroup m2 on
			m1.MUGroupId=m2.rf_MUGroupId 
						inner join OMS_NSI.dbo.sprMU m3 on
			m2.MUUnGroupId=m3.rf_MUUnGroupId
						INNER JOIN  oms_nsi.dbo.sprV008 v008 ON
			m3.rf_sprV008Id=v008.Id
WHERE m3.ST =1	
UNION ALL
SELECT tCSG.code
	   ,tCSG.name
	   ,v.id
	   ,v.Name
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGType t1 ON
				tCSG.rf_CSGTypeId=t1.CSGTypeId
								INNER JOIN OMS_NSI.dbo.tCSGV008Relation rfV008 ON
				tCSG.CSGroupId=rfV008.rf_CSGroupID
								INNER JOIN OMS_NSI.dbo.sprV008 v ON
				rfV008.rf_sprV008Id=v.[UId]		
GO