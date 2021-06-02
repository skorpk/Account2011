USE RegisterCases
go
if OBJECT_ID('sprLPUEnableCalendar',N'U') is not null
drop table sprLPUEnableCalendar
go
create table sprLPUEnableCalendar
(
	CodeM varchar(6),--код МО
	typePR_NOV bit-- 1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
)
go
