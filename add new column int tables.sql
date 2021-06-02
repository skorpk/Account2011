USE AccountOMS
go
SET NOCOUNT ON
alter table t_Case add [Emergency] tinyint null
alter table dbo.t_RecordCasePatient add AttachLPU char(6) null
go
use RegisterCases
go
alter table dbo.t_RecordCase add AttachLPU char(6) null