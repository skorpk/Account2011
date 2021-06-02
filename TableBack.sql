use Accounts2011
go
---Back Register --- Added 22.09.2011
if(OBJECT_ID('t_FileBack',N'U')) is not null
	drop table dbo.t_FileBack
go
create table dbo.t_FileBack
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFiles int not null CONSTRAINT FK_FileBack_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id),
	DateCreate datetime not null CONSTRAINT DF_DateCreateFileBack DEFAULT (GETDATE()),
	FileVersion char(5) not null DEFAULT '1.1',
	[FileNameHRBack] varchar(26) not null,
	UserName varchar(30) not null CONSTRAINT DF_UserNameFileBack default (ORIGINAL_LOGIN())
)
go
if(OBJECT_ID('t_RecordCaseBack',N'U')) is not null
	drop table dbo.t_RecordCaseBack
go
create table dbo.t_RecordCaseBack
(
	rf_idFilesBack int not null CONSTRAINT FK_RecordCaseBack_FilesBack FOREIGN KEY(rf_idFilesBack) REFERENCES dbo.t_FileBack(id),
	rf_idRecordCase smallint not null,
	GUID_Case uniqueidentifier not null,
	rf_idFilesRecordCase int not null,
	CONSTRAINT PK_RecordCaseBack PRIMARY KEY CLUSTERED (rf_idFilesBack,rf_idRecordCase)
)
go
if(OBJECT_ID('t_PatientBack',N'U')) is not null
	drop table dbo.t_PatientBack
go
create table dbo.t_PatientBack
(
	rf_idFilesBack int not null,
	rf_idRecordCase smallint not null,
	GUID_Patient varchar(36) not null,
	rf_idF008 tinyint not null,
	SeriaPolis varchar(10) null,
	NumberPolis varchar(20) not null,
	rf_idSMO char(5) not null,
	OKATO char(5) null,
	DateDefine datetime default(getdate()),
	IsRegional bit,
	CONSTRAINT FK_PatientBack_RecordCaseBack FOREIGN KEY(rf_idFilesBack,rf_idRecordCase) REFERENCES dbo.t_RecordCaseBack(rf_idFilesBack,rf_idRecordCase)
)
go

if(OBJECT_ID('t_CaseBack',N'U')) is not null
	drop table dbo.t_CaseBack
go
create table dbo.t_CaseBack
(
	rf_idFilesBack int null,
	rf_idRecordCase smallint not null,
	GUID_Case uniqueidentifier not null,
	TypePay tinyint not null,
	CONSTRAINT FK_CaseBack_Cases FOREIGN KEY(GUID_Case) REFERENCES dbo.t_Case(GUID_Case),
	CONSTRAINT FK_CaseBack_RecordCaseBack FOREIGN KEY(rf_idFilesBack,rf_idRecordCase) REFERENCES dbo.t_RecordCaseBack(rf_idFilesBack,rf_idRecordCase)
)
go



