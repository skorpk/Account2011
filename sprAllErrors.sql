USE OMS_NSI
go
if OBJECT_ID('sprAllErrors',N'U') is not null
drop table sprAllErrors
go
create table sprAllErrors
(
	Code smallint,
	Error varchar(90),
	DescriptionError varchar(250),
	DateBeg date,
	Reason varchar(10)	
)
go