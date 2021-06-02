USE RegisterCases
go


SELECT t.rf_idFile,t.rf_idFileBack,t.UnitCode
INTO #t
FROM tmp_PlanOrdersReport t INNER JOIN dbo.t_PlanOrdersReport p ON
			t.rf_idFile=p.rf_idFile
			AND t.rf_idFileBack=p.rf_idFileBack
			AND p.UnitCode=t.UnitCode
WHERE t.UnitCode=259 AND p.MonthReport<4

BEGIN TRANSACTION

DELETE FROM dbo.t_PlanOrdersReport
FROM dbo.t_PlanOrdersReport p INNER JOIN #t t ON
		t.rf_idFile=p.rf_idFile
		AND t.rf_idFileBack=p.rf_idFileBack
		AND p.UnitCode=t.UnitCode

INSERT dbo.t_PlanOrdersReport( rf_idFile ,rf_idFileBack ,CodeLPU ,UnitCode ,Vm ,Vdm ,Spred ,MonthReport ,YearReport)
SELECT p.rf_idFile ,p.rf_idFileBack ,CodeLPU ,p.UnitCode ,Vm ,Vdm ,Spred ,MonthReport ,YearReport
FROM dbo.tmp_PlanOrdersReport p INNER JOIN #t t ON
		t.rf_idFile=p.rf_idFile
		AND t.rf_idFileBack=p.rf_idFileBack
		AND p.UnitCode=t.UnitCode

commit
GO
DROP TABLE #t