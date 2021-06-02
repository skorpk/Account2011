USE [RegisterCases]
GO

ALTER VIEW [dbo].[vw_sprPriceLevelMO]
AS
SELECT LEFT(t.tfomsCode,6) AS CodeM,
		NULL AS DeptCode,
	  c.code AS rf_idV006
	  ,l.MSLevelId AS LevelPayType
	  ,p.beginDate AS DateBegin
	  ,p.endDate AS DateEnd
FROM oms_NSI.dbo.tMSPricePeriod p INNER JOIN oms_NSI.dbo.tMSCondition c ON 
			p.rf_MSConditionId = c.MSConditionId 
								INNER JOIN oms_NSI.dbo.tMSLevel l ON 
			p.rf_MSLevelId = l.MSLevelId
								inner join oms_NSI.dbo.tMO t on
			p.rf_MOId=t.MOId
UNION ALL
SELECT LEFT(ISNULL(B.tfomsCode,D.tfomsCode),6) AS CodeM, 
            C.code AS DeptCode, 
            A.rf_MSConditionId AS rf_idV006,
            A.rf_LevelId AS LevelPayType, 
            A.dateBeg AS DateBegin, 
            A.dateEnd AS DateEnd 
FROM  oms_NSI.dbo.tMOLevel A LEFT JOIN oms_NSI.dbo.tMO B ON 
		A.rf_MOId = B.MOId 
				LEFT JOIN oms_NSI.dbo.tMODept C ON 
		A.rf_MODeptId = C.MODeptId 
			    LEFT JOIN oms_NSI.dbo.tMO D ON 
		C.rf_MOId = D.MOId
GO
GRANT SELECT ON vw_sprPriceLevelMO TO db_RegisterCase


