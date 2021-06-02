USE RegisterCases
GO
--SELECT * 
--FROM dbo.vw_getFileBack2 WHERE ReportYear=2016 AND CodeM='175709'

--SELECT *
--FROM dbo.t_PlanOrdersReport WHERE rf_idFileBack=136468

;WITH cte
AS(
SELECT DISTINCT rf_idFile,rf_idFileBack, UnitCode
FROM dbo.t_PlanOrdersReport 
WHERE YearReport=2016 AND Spred-Vdm-Vm>0
) 
SELECT v.*,c.*
FROM cte c INNER JOIN dbo.vw_getFileBack2 v ON
		c.rf_idFileBack=v.idFileBack
ORDER BY DateCreate

exec usp_PlanOrdersReportTest @idFile=78099,@idFileBack=136617

--SELECT * FROM dbo.vw_sprUnit WHERE unitCode=34