USE RegisterCases
GO
DECLARE @codeLPU VARCHAR(6),
		@month TINYINT,
		@year SMALLINT
        
SELECT @codeLPU=CodeM,@month=ReportMonth,@year=ReportYear
FROM dbo.vw_getFileBack WHERE DateCreate>'20180101'	AND AmountCasesPayed>500 ORDER BY NEWID()

create table #tmpPlan
(
	CodeLPU varchar(6),
	UnitCode int,
	Vm DECIMAL(11,2),
	Vdm DECIMAL(11,2),
	Spred decimal(11,2),
	[month] tinyint
)
EXEC dbo.usp_PlanOrders @codeLPU ,@month ,@year 
GO
DROP TABLE #tmpPlan