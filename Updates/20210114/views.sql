USE RegisterCases
GO
--CREATE VIEW vw_tCSGBasePrice
--as
--SELECT v6.Id,p.price,p.dateBeg,p.dateEnd
--FROM oms_nsi.dbo.tCSGBasePrice p INNER JOIN dbo.sprV006 v6 ON
--			p.rf_MSConditionId=v6.Id
--go
CREATE VIEW vw_tCSGResourceConsuming
as
SELECT c.code,w.coefficient,w.dateBeg,w.dateEnd
FROM dbo.vw_sprCSG c INNER JOIN oms_nsi.dbo.tCSGResourceConsuming w ON
				c.CSGroupId=w.rf_CSGroupID
WHERE w.dateBeg>'20190101'
GO
GRANT SELECT ON vw_tCSGResourceConsuming TO db_RegisterCase
GO
CREATE VIEW vw_tCSGManagement
as
SELECT c.code,w.coefficient,w.dateBeg,w.dateEnd
FROM dbo.vw_sprCSG c INNER JOIN oms_nsi.dbo.tCSGManagement w ON
				c.CSGroupId=w.rf_CSGroupID
WHERE w.dateBeg>'20190101'
GO

GRANT SELECT ON vw_tCSGManagement TO db_RegisterCase
GO
--DROP VIEW vw_CSGLevel
CREATE VIEW vw_CSGLevel
AS
WITH cteLevel
AS(
	SELECT      LEFT(ISNULL(B.tfomsCode,D.tfomsCode),6) AS CodeM, 
				C.code AS DeptCode, 
				A.rf_MSConditionId AS rf_idV006,
				E.levelPay AS LevelPayType, 
				A.dateBeg AS DateBegin, 
				A.dateEnd AS DateEnd 
				,e.LevelId
	FROM  oms_NSI.dbo.tMOLevel A INNER JOIN oms_NSI.dbo.sprLevel E ON A.rf_LevelId = E.LevelId
				LEFT OUTER JOIN oms_NSI.dbo.tMO B ON A.rf_MOId = B.MOId 
				LEFT OUTER JOIN oms_NSI.dbo.tMODept C ON A.rf_MODeptId = C.MODeptId 
				LEFT OUTER JOIN oms_NSI.dbo.tMO D ON C.rf_MOId = D.MOId 
	WHERE A.dateBeg>'20200101'
)
SELECT c.CodeM,
       c.DeptCode,
       c.rf_idV006,
       c.LevelPayType,
       c.DateBegin,
       c.DateEnd,
       c.LevelId,
	   l.coefficient,
	   l.dateBeg AS DateBegLevel,
	   l.dateEnd AS DateEndLevel
FROM cteLevel c INNER JOIN oms_nsi.dbo.sprLevelCoefficient l ON
		c.LevelId=l.rf_LevelId
WHERE l.dateBeg>'20200101'
go
GRANT SELECT ON vw_CSGLevel TO db_RegisterCase
go
