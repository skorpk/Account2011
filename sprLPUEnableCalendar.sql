USE RegisterCases
go
if OBJECT_ID('sprLPUEnableCalendar',N'U') is not null
drop table sprLPUEnableCalendar
go
create table sprLPUEnableCalendar
(
	CodeM varchar(6),--��� ��
	typePR_NOV bit-- 1 �� ��� PRN_NOV=1, ���� 0 �� ��� PRN_NOV=0
)
go
