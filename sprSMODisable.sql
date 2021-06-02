use oms_NSI
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('sprSMODisable',N'U')) is not null
	drop table dbo.sprSMODisable
go
create table dbo.sprSMODisable
(
	id int identity(1,1),
	SMO char(5),
	DateEnd date
)
go
insert dbo.sprSMODisable(SMO,DateEnd) values('34003','20111201')
go

