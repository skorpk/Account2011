USE RegisterCases
go
if OBJECT_ID('sprCalendarPR_NOV0',N'U') is not null
drop table sprCalendarPR_NOV0
go
create table sprCalendarPR_NOV0
(
	ReportMonth tinyint,
	ReportYear smallint,
	ReportDate1 date,
	ReportDate2 date,
	ControlDate1 date,
	ControlDate2 date
)
go
insert sprCalendarPR_NOV0(ReportMonth,ReportYear)
values(1,2012),(2,2012),(3,2012),(4,2012),(5,2012),(6,2012),(7,2012),(8,2012),(9,2012),(10,2012),(11,2012),(12,2012)
go
if OBJECT_ID('sprCalendarPR_NOV1',N'U') is not null
drop table sprCalendarPR_NOV1
go
create table sprCalendarPR_NOV1
(
	ReportYear smallint,
	ControlDateDay tinyint
)
go
insert sprCalendarPR_NOV1(ReportYear,ControlDateDay) values(2012,3)