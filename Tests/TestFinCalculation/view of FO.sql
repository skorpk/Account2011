USE RegisterCases
GO
CREATE VIEW vw_sprFOCode_UnitCode
as
WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY u.unitCode ORDER BY f.code) AS rowId,f.code AS CodeFO,f.name AS NameFO,u.unitCode,u.unitName,f.dateBeg,f.dateEnd, f.rf_MSConditionId,c.code AS TypePF
FROM oms_NSI.dbo.tFinSecUnitPlanUnitRel t JOIN oms_NSI.dbo.tFinSecurityUnit f ON
			t.rf_FinSecurityUnitId=f.FinSecurityUnitId
							JOIN oms_NSI.dbo.tPlanUnit u ON
            t.rf_PlanUnitId=u.PlanUnitId				
							left JOIN oms_nsi.dbo.sprTypeOfCalculation c ON
			f.rf_TypeOfCalculationId=c.id			
WHERE f.dateBeg='20210101'
)
SELECT TOP(10000) *
FROM cte ORDER BY cte.unitCode, rowId
go