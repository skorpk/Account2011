USE oms_NSI
GO
if(OBJECT_ID('sprSpecialCase',N'U')) is not null
	drop table dbo.sprSpecialCase
go
create table dbo.sprSpecialCase
(
	OS_SLUCH TINYINT PRIMARY KEY,
	IsClinincalExamination bit	
)
GO
INSERT sprSpecialCase(OS_SLUCH,IsClinincalExamination) VALUES(2,0),(3,1),(4,1),(23,1),(24,1)
GO
SELECT * FROM sprSpecialCase