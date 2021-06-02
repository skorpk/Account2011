use RegisterCases
go
--declare @codeLPU char(6)='101001'
--		,@month tinyint=2
--		,@year smallint=2012
	
--select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)
CREATE TABLE #t
(
	unitCode tinyint,
	unitName varchar(50),
	MEK int,
	Utv int,
	Spred int,
	Diff decimal(11,2),
	ReportDate varchar(30),
	LPU varchar(100),
	NumberRegister varchar(10),
	[Percent] decimal(15,2)
)
insert #t exec usp_PlanOrdersReportNew @idFileBack=7464
insert #t exec usp_PlanOrdersReportNew @idFileBack=7260
insert #t exec usp_PlanOrdersReportNew @idFileBack=7204
insert #t exec usp_PlanOrdersReportNew @idFileBack=7203
insert #t exec usp_PlanOrdersReportNew @idFileBack=7083
insert #t exec usp_PlanOrdersReportNew @idFileBack=7342
insert #t exec usp_PlanOrdersReportNew @idFileBack=6996
insert #t exec usp_PlanOrdersReportNew @idFileBack=7341
insert #t exec usp_PlanOrdersReportNew @idFileBack=6841
insert #t exec usp_PlanOrdersReportNew @idFileBack=7184
insert #t exec usp_PlanOrdersReportNew @idFileBack=6481
insert #t exec usp_PlanOrdersReportNew @idFileBack=6701
insert #t exec usp_PlanOrdersReportNew @idFileBack=6692
insert #t exec usp_PlanOrdersReportNew @idFileBack=6480
insert #t exec usp_PlanOrdersReportNew @idFileBack=6759
insert #t exec usp_PlanOrdersReportNew @idFileBack=6280
insert #t exec usp_PlanOrdersReportNew @idFileBack=6045
insert #t exec usp_PlanOrdersReportNew @idFileBack=6273
insert #t exec usp_PlanOrdersReportNew @idFileBack=5451
insert #t exec usp_PlanOrdersReportNew @idFileBack=5817
insert #t exec usp_PlanOrdersReportNew @idFileBack=5855
insert #t exec usp_PlanOrdersReportNew @idFileBack=5384
insert #t exec usp_PlanOrdersReportNew @idFileBack=5383
insert #t exec usp_PlanOrdersReportNew @idFileBack=5808
insert #t exec usp_PlanOrdersReportNew @idFileBack=5612
insert #t exec usp_PlanOrdersReportNew @idFileBack=5189
insert #t exec usp_PlanOrdersReportNew @idFileBack=5188
insert #t exec usp_PlanOrdersReportNew @idFileBack=5568
insert #t exec usp_PlanOrdersReportNew @idFileBack=4975
insert #t exec usp_PlanOrdersReportNew @idFileBack=5119
insert #t exec usp_PlanOrdersReportNew @idFileBack=4917
insert #t exec usp_PlanOrdersReportNew @idFileBack=4562
insert #t exec usp_PlanOrdersReportNew @idFileBack=4561
insert #t exec usp_PlanOrdersReportNew @idFileBack=4880
insert #t exec usp_PlanOrdersReportNew @idFileBack=4878
insert #t exec usp_PlanOrdersReportNew @idFileBack=4498
insert #t exec usp_PlanOrdersReportNew @idFileBack=4497
insert #t exec usp_PlanOrdersReportNew @idFileBack=4870
insert #t exec usp_PlanOrdersReportNew @idFileBack=4305
insert #t exec usp_PlanOrdersReportNew @idFileBack=4767
insert #t exec usp_PlanOrdersReportNew @idFileBack=4488
insert #t exec usp_PlanOrdersReportNew @idFileBack=4177

select * from #t

drop table #t 
