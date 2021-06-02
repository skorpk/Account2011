use RegisterCases
go
if(OBJECT_ID('t_RefCaseAttachLPUItearion2',N'U')) is not null
	drop table dbo.t_RefCaseAttachLPUItearion2
go
create table dbo.t_RefCaseAttachLPUItearion2
(
	rf_idCase BIGINT NOT null,
	rf_idFiles INT NOT null,
	rf_idRefCaseIteration BIGINT NOT NULL,
	AttachLPU VARCHAR(6) NULL,
	PID INT NOT null
)
go