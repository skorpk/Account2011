USE RegisterCases
GO
ALTER VIEW vw_sprFOCode_UnitCode
as
WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY u.unitCode ORDER BY f.code) AS rowId,f.code AS CodeFV,f.name AS NameFO,u.unitCode,u.unitName,f.dateBeg,f.dateEnd, f.rf_MSConditionId
	,c.code AS TypePF,c.Name AS NameTypePF, fp.rf_QuarterId AS [Quarter],fp.[year] AS YearFV
FROM oms_NSI.dbo.tFinSecUnitPlanUnitRel t JOIN oms_NSI.dbo.tFinSecurityUnit f ON
			t.rf_FinSecurityUnitId=f.FinSecurityUnitId
							JOIN oms_NSI.dbo.tPlanUnit u ON
            t.rf_PlanUnitId=u.PlanUnitId	
							JOIN oms_nsi.dbo.tFinSecurityPlan fp ON
			f.FinSecurityUnitId=fp.rf_FinSecurityUnitId			
							left JOIN oms_nsi.dbo.sprTypeOfCalculation c ON
			f.rf_TypeOfCalculationId=c.id			
WHERE f.dateBeg='20210101'
)
SELECT TOP(10000) *
FROM cte ORDER BY cte.unitCode, rowId
GO
--------------------------------------------------------------------
alter VIEW vw_sprFS_SUM_MO
as
SELECT f.code AS CodeFV,f.name AS NameFO,u.unitCode,u.unitName,f.dateBeg,f.dateEnd,fp.unit_sum AS SumFV,LEFT(m.tfomsCode,6) AS CodeM, f.rf_MSConditionId
,fp.rf_QuarterId AS [Quarter],fp.[year] AS YearFV
FROM oms_nsi.dbo.tFinSecUnitPlanUnitRel t JOIN oms_nsi.dbo.tFinSecurityUnit f ON
			t.rf_FinSecurityUnitId=f.FinSecurityUnitId
							JOIN oms_nsi.dbo.tPlanUnit u ON
            t.rf_PlanUnitId=u.PlanUnitId
							JOIN oms_nsi.dbo.tFinSecurityPlan fp ON
			f.FinSecurityUnitId=fp.rf_FinSecurityUnitId
							JOIN oms_nsi.dbo.sprTypeOfCalculation s ON
			f.rf_TypeOfCalculationId=s.id
							JOIN oms_nsi.dbo.tMO m ON
            fp.rf_MOId=m.MOId							
WHERE f.dateBeg='20210101'
GO
alter VIEW vw_FS_Profil_Calc
AS
SELECT v2.id AS ProfilID,v2.Name AS Profil, tv.dateBeg, tv.dateEnd,s.code,s.name AS nameCalc
FROM oms_nsi.dbo.tTypeOfCalcV002Rel tv JOIN oms_nsi.dbo.sprV002 v2 ON
			tv.rf_V002UId=v2.UId
					JOIN oms_nsi.dbo.sprTypeOfCalculation s ON
			tv.rf_TypeOfCalculationId=s.id
go