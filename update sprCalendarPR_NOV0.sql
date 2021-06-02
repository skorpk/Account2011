USE RegisterCases
go
SET NOCOUNT ON
select * from sprCalendarPR_NOV0

begin transaction
-----update dates for november
update sprCalendarPR_NOV0
set ReportDate1=dateadd(month,1,dateadd(day,1-day(cast(ReportYear as CHAR(4))+right('0'+cast(ReportMonth as VARCHAR(2)),2)+'01'),
	cast(ReportYear as CHAR(4))+right('0'+cast(ReportMonth as VARCHAR(2)),2)+'01')) 
	,ReportDate2=dateadd(month,1,dateadd(day,1-day(cast(ReportYear as CHAR(4))+right('0'+cast(ReportMonth as VARCHAR(2)),2)+'01'),
	cast(ReportYear as CHAR(4))+right('0'+cast(ReportMonth as VARCHAR(2)),2)+'01')) 
where ReportMonth<11 and ReportYear=2012
---update dates fro december
update sprCalendarPR_NOV0
set ControlDate1=dateadd(DAY,4,ReportDate1),ControlDate2=dateadd(Day,4,ReportDate1)
where ReportMonth<11 and ReportYear=2012

select * from sprCalendarPR_NOV0
commit


go