use RegisterCases
go
if OBJECT_ID('t_LPUPlanOrdersDisabled',N'U') is not null
	drop table t_LPUPlanOrdersDisabled
go
create table t_LPUPlanOrdersDisabled
(
	CodeM char(6),
	ReportYear smallint,
	BeforeDate date
)
go
insert t_LPUPlanOrdersDisabled values('101001',2011,'20120520')