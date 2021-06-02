use RegisterCases
go
if(OBJECT_ID('sprIteration',N'U')) is not null
	drop table dbo.sprIteration
go
create table dbo.sprIteration
(
	id tinyint not null PRIMARY KEY,
	NAME varchar(70),
	IsRegional bit,
	IsDateEnd bit
)
go
insert sprIteration(id,NAME,IsRegional,IsDateEnd) values(1,'Поиск в РС ЕРП на дату окончания лечения',1,1),
														(2,'Поиск в ЕС ЕРП на дату окончания лечения',0,1),
														(3,'Поиск в РС ЕРП последней страховой принадлежности',1,0),
														(4,'Поиск в ЕС ЕРП последней страховой принадлежности',0,0)
GO
if(OBJECT_ID('t_RefCasePatientDefine',N'U')) is not null
	drop table dbo.t_RefCasePatientDefine
go
create table dbo.t_RefCasePatientDefine
(
	id bigint IDENTITY(1,1) NOT NULL,
	rf_idCase bigint NOT NULL,
	--rf_idIteration tinyint null ,
	rf_idRegisterPatient int not null,
	CONSTRAINT PK_ZP1_RecordCase PRIMARY KEY CLUSTERED 
	(
		id ASC
	)
)
alter table dbo.t_RefCasePatientDefine add rf_idFiles int
go
alter table dbo.t_RefCasePatientDefine add IsUnloadIntoSP_TK bit null
go


if(OBJECT_ID('t_CaseDefine',N'U')) is not null
	drop table dbo.t_CaseDefine
go
create table dbo.t_CaseDefine
(
	rf_idRefCaseIteration bigint not null CONSTRAINT FK_CaseDefine_RefCaseIteration FOREIGN KEY(rf_idRefCaseIteration) REFERENCES dbo.t_RefCasePatientDefine(id),
	DateDefine datetime not null,
	PID int null,
	UniqueNumberPolicy varchar(20) not null,
	IsDefined bit not null,
	SMO varchar(5) not null,
	SPolicy varchar(20) null,
	NPolcy varchar(20) null,
	RN varchar(11) null,
	rf_idF008 tinyint null
)
go
alter table t_CaseDefine alter column UniqueNumberPolicy varchar(20) null
go
if(OBJECT_ID('t_CasePatientDefineIteration',N'U')) is not null
	drop table dbo.t_CasePatientDefineIteration
go
create table dbo.t_CasePatientDefineIteration
(
	rf_idRefCaseIteration bigint not null CONSTRAINT FK_RefCasePatientIterationDefine FOREIGN KEY(rf_idRefCaseIteration) REFERENCES dbo.t_RefCasePatientDefine(id),
	rf_idIteration tinyint null 
)
go 
ALTER TABLE dbo.t_CasePatientDefineIteration  WITH CHECK ADD  CONSTRAINT FK_sprIteration FOREIGN KEY(rf_idIteration)
REFERENCES dbo.sprIteration(id)
GO
ALTER TABLE dbo.t_CasePatientDefineIteration CHECK CONSTRAINT FK_sprIteration
GO

if(OBJECT_ID('t_CaseDefineZP1',N'U')) is not null
	drop table dbo.t_CaseDefineZP1
go
create table dbo.t_CaseDefineZP1
(
	rf_idRefCaseIteration bigint not null CONSTRAINT FK_CaseIterationZP1_RefCaseIteration FOREIGN KEY(rf_idRefCaseIteration) REFERENCES dbo.t_RefCasePatientDefine(id),
	rf_idZP1 int not null,
	DateOperationt datetime not null default(getdate())
)
go
if(OBJECT_ID('t_CaseDefineZP1Found',N'U')) is not null
	drop table dbo.t_CaseDefineZP1Found
go
create table dbo.t_CaseDefineZP1Found
(
	rf_idRefCaseIteration bigint not null,
	rf_idZP1 int not null,
	OKATO varchar(5),
	UniqueNumberPolicy varchar(20) null,
	TypePolicy char(1) null,
	OGRN_SMO varchar(15) null,
	SPolicy varchar(20) null,
	NPolcy varchar(20) null,
	DateDefine datetime 
)
go