USE RegisterCases
GO
DECLARE @codeLPU VARCHAR(6)='165531',
		@month TINYINT =3,
		@year SMALLINT=2018
		create table #tmpPlan
		(
			CodeLPU varchar(6),
			UnitCode int,
			Vm int,
			Vdm int,
			Spred decimal(11,2),
			[month] tinyint
		)
		EXEC dbo.usp_PlanOrders @codeLPU,@month,@year
SELECT * FROM #tmpPlan WHERE UnitCode=260
go

DROP TABLE #tmpPlan