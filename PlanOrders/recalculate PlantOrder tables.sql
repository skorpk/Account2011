USE RegisterCases
GO
create table #tmpPlan
		(
			rf_idFile INT,
			rf_idFileBack INT,
			CodeLPU varchar(6),
			UnitCode int,
			Vm int,
			Vdm int,
			Spred decimal(11,2),
			MonthReport TINYINT,
			YearReport smallint
		)
DECLARE @i SMALLINT=1

		declare cPlan cursor for
			select rf_idFiles,idFileBack from dbo.vw_getFileBack2 WHERE ReportYear=2018 AND CodeM='141023' AND idFileBack IN(218274,218199,218194,218172,218147,218132)
			declare @idFile int, @idFileBack INT
		open cPlan
		fetch next from cPlan into @idFile, @idFileBack
		while @@FETCH_STATUS = 0
		begin				
			 INSERT #tmpPlan exec usp_PlanOrdersReport @idFile,@idFileBack
			 PRINT(@i)
			 SET @i=@i+1
			fetch next from cPlan into @idFile, @idFileBack
		end
		close cPlan
		deallocate cPlan



SELECT DISTINCT rf_idFileBack
INTO #tmpBack
FROM #tmpPlan t 
WHERE NOT EXISTS(SELECT * FROM dbo.t_PlanOrdersReport WHERE rf_idFileBack=t.rf_idFileBack AND UnitCode=t.UnitCode AND Spred=t.Spred)

---пересчет данных в основной таблице
BEGIN TRANSACTION
DELETE FROM dbo.t_PlanOrdersReport
FROM dbo.t_PlanOrdersReport t
WHERE EXISTS(SELECT * FROM #tmpBack WHERE rf_idFileBack=t.rf_idFileBack)

INSERT dbo.t_PlanOrdersReport( rf_idFile ,rf_idFileBack ,CodeLPU ,UnitCode ,Vm ,Vdm ,Spred ,MonthReport ,YearReport)
SELECT *
FROM #tmpPlan t
WHERE EXISTS(SELECT * FROM #tmpBack WHERE rf_idFileBack=t.rf_idFileBack)

EXEC dbo.usp_PlanOrdersReportTotal @dateReg = '20180410', -- datetime
    @Quarter =1, -- tinyint
    @year = 2018 -- smallint

rollback	
*/
go
DROP TABLE #tmpPlan
DROP TABLE #tmpBack
		