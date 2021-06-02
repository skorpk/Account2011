USE RegisterCases
GO
--пересчет единиц учета по Диспансеризации 1 этап по медуслугам.
SELECT rf_idFile,rf_idFileBack 
INTO #t
FROM t_PlanOrdersReport p INNER JOIN (VALUES ('254505'),('251001'),('255802'),('471001'),('521001')) v(CodeM) ON
		p.CodeLPU=v.CodeM
WHERE YearReport=2015 and MonthReport>3 AND MonthReport<=6 
GROUP BY rf_idFile,rf_idFileBack 




CREATE TABLE #tPlan
(
[rf_idFile] [int] NULL,
[rf_idFileBack] [int] NULL,
[CodeLPU] [varchar] (6) COLLATE Cyrillic_General_CI_AS NULL,
[UnitCode] [int] NULL,
[Vm] [int] NULL,
[Vdm] [int] NULL,
[Spred] [decimal] (11, 2) NULL,
[MonthReport] [tinyint] NULL,
[YearReport] [smallint] NULL,
[TotalVm] AS ([Vdm]+[Vm])
) 

	declare cPlan cursor for
			SELECT rf_idFile,rf_idFileBack from #t
			declare @idFile int,@rf_idFileBack int
		open cPlan
		fetch next from cPlan into @idFile ,@rf_idFileBack
		while @@FETCH_STATUS = 0
		BEGIN
			INSERT #tPlan (rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
			EXEC dbo.usp_PlanOrdersReport_Test  @idFile,@rf_idFileBack			
			fetch next from cPlan into @idFile,@rf_idFileBack
		end
		close cPlan
		deallocate cPlan

SELECT *
FROM #tPlan p INNER JOIN t_PlanOrdersReport p1 ON
		p.rf_idFile=p1.rf_idFile
		AND p.rf_idFileBack=p1.rf_idFileBack
		AND p.UnitCode=p1.UnitCode
WHERE p.Spred<>p1.Spred 



UPDATE p1 SET p1.Spred=p.Spred
FROM #tPlan p INNER JOIN t_PlanOrdersReport p1 ON
		p.rf_idFile=p1.rf_idFile
		AND p.rf_idFileBack=p1.rf_idFileBack
		AND p.UnitCode=p1.UnitCode
WHERE p.Spred<>p1.Spred 

go
drop table #t
drop table #tPlan
