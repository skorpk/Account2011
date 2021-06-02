USE oms_NSI
GO
SELECT v2.Id,v2.Name,tv.dateBeg,tv.dateEnd
FROM dbo.tTypeOfCalcV002Rel tv JOIN dbo.sprV002 v2 ON
			tv.rf_V002UId=v2.UId
ORDER BY v2.id

--SELECT v2.Id,v2.Name,tv.dateBeg,tv.dateEnd
--FROM dbo.tTypeOfCalcV002Rel tv JOIN dbo.sprV002 v2 ON
--			tv.rf_V002UId=v2.UId
--ORDER BY v2.id
--	OFFSET 10 ROWS
--    FETCH NEXT 10 ROWS ONLY



SELECT f.code AS CodeFO,f.name AS NameFO,u.unitCode,u.unitName,f.dateBeg,f.dateEnd,fp.unit_sum,LEFT(m.tfomsCode,6) AS CodeM, f.rf_MSConditionId,fp.year
FROM dbo.tFinSecUnitPlanUnitRel t JOIN dbo.tFinSecurityUnit f ON
			t.rf_FinSecurityUnitId=f.FinSecurityUnitId
							JOIN dbo.tPlanUnit u ON
            t.rf_PlanUnitId=u.PlanUnitId
							JOIN dbo.tFinSecurityPlan fp ON
			f.FinSecurityUnitId=fp.rf_FinSecurityUnitId
							JOIN dbo.sprTypeOfCalculation s ON
			f.rf_TypeOfCalculationId=s.id
							JOIN dbo.tMO m ON
            fp.rf_MOId=m.MOId
WHERE f.dateBeg='20210101'

SELECT t.*,f.code AS CodeFO,f.name AS NameFO,u.unitCode,u.unitName,f.dateBeg,f.dateEnd, f.rf_MSConditionId
FROM oms_NSI.dbo.tFinSecUnitPlanUnitRel t JOIN oms_NSI.dbo.tFinSecurityUnit f ON
			t.rf_FinSecurityUnitId=f.FinSecurityUnitId
							JOIN oms_NSI.dbo.tPlanUnit u ON
            t.rf_PlanUnitId=u.PlanUnitId							
WHERE f.dateBeg='20210101'
/*
SELECT * FROM dbo.tFinSecurityUnit

SELECT * FROM dbo.sprTypeOfCalculation

SELECT max(DateEnd),max(dateBeg) FROM dbo.tFinSecurityUnit

SELECT * FROM dbo.vw_sprFinanceInfoByQuater
*/
