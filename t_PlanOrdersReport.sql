use RegisterCases
go
if(OBJECT_ID('t_PlanOrdersReport',N'U')) is not null
	drop table dbo.t_PlanOrdersReport
go
create table dbo.t_PlanOrdersReport
(
	rf_idFile int,
	rf_idFileBack int,
	CodeLPU varchar(6),
	UnitCode int,
	Vm int,
	Vdm int,
	Spred int,
	MonthReport tinyint,
	YearReport smallint
)
go
