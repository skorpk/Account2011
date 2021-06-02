use RegisterCases
go
---Back Register --- Added 22.09.2011
if(OBJECT_ID('t_FileBack',N'U')) is not null
	drop table dbo.t_FileBack
go
create table dbo.t_FileBack
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFiles int not null ,--CONSTRAINT FK_FileBack_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id),
	DateCreate datetime not null CONSTRAINT DF_DateCreateFileBack DEFAULT (GETDATE()),
	FileVersion char(5) not null DEFAULT '1.1',
	FileNameHRBack varchar(26) not null,
	UserName varchar(30) not null CONSTRAINT DF_UserNameFileBack default (ORIGINAL_LOGIN())
)
go
alter table dbo.t_FileBack add IsUnload bit DEFAULT(0)
if(OBJECT_ID('t_RegisterCaseBack',N'U')) is not null
	drop table dbo.t_RegisterCaseBack
go
create table t_RegisterCaseBack
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFilesBack int NOT NULL CONSTRAINT FK_RegistersCasesBack_FilesBack FOREIGN KEY(rf_idFilesBack) REFERENCES dbo.t_FileBack(id),
	ref_idF003 char(6) not null,
	ReportYear smallint not null,
	ReportMonth tinyint not null,
	DateCreate date not null,
	NumberRegister int not null,
	PropertyNumberRegister tinyint not null,
	Comments varchar(250) null
)
GO
if(OBJECT_ID('t_RecordCaseBack',N'U')) is not null
	drop table dbo.t_RecordCaseBack
go
CREATE TABLE dbo.t_RecordCaseBack
(
	id int IDENTITY(1,1) NOT NULL,
	rf_idRegisterCaseBack int NOT NULL,
	rf_idRecordCase int NOT NULL,
	rf_idCase bigint NOT NULL,
CONSTRAINT PK_RecordCaseBack PRIMARY KEY CLUSTERED 
(
	id ASC
))

GO

ALTER TABLE dbo.t_RecordCaseBack  WITH CHECK ADD  CONSTRAINT FK_RecordCaseBack_RegisterCaseBack FOREIGN KEY(rf_idRegisterCaseBack)
REFERENCES dbo.t_RegisterCaseBack (id)
GO

ALTER TABLE dbo.t_RecordCaseBack CHECK CONSTRAINT FK_RecordCaseBack_RegisterCaseBack
GO

ALTER TABLE dbo.t_RecordCaseBack  WITH CHECK ADD  CONSTRAINT FK_RecordCaseBack_RecordCase FOREIGN KEY(rf_idRecordCase)
REFERENCES dbo.t_RecordCase (id)
GO

ALTER TABLE dbo.t_RecordCaseBack CHECK CONSTRAINT FK_RecordCaseBack_RecordCase
go
if(OBJECT_ID('t_PatientBack',N'U')) is not null
	drop table dbo.t_PatientBack
go
CREATE TABLE dbo.t_PatientBack(
	rf_idRecordCaseBack int NOT NULL,
	--GUID_Patient varchar(36) NOT NULL,
	rf_idF008 tinyint NOT NULL,
	SeriaPolis varchar(10) NULL,
	NumberPolis varchar(20) NOT NULL,
	rf_idSMO char(5) NOT NULL,
	OKATO char(5) NULL,
) ON RegisterCases

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE dbo.t_PatientBack  WITH CHECK ADD  CONSTRAINT FK_PatientBack_RecordCaseBack FOREIGN KEY(rf_idRecordCaseBack)
REFERENCES dbo.t_RecordCaseBack (id)
GO

ALTER TABLE dbo.t_PatientBack CHECK CONSTRAINT FK_PatientBack_RecordCaseBack
GO

if(OBJECT_ID('t_CaseBack',N'U')) is not null
	drop table dbo.t_CaseBack
go
CREATE TABLE dbo.t_CaseBack
(
	rf_idRecordCaseBack int NOT NULL,
	TypePay tinyint NOT NULL
)

GO

ALTER TABLE dbo.t_CaseBack  WITH CHECK ADD  CONSTRAINT FK_CaseBack_RecordCaseBack FOREIGN KEY(rf_idRecordCaseBack)
REFERENCES dbo.t_RecordCaseBack (id)
GO

ALTER TABLE dbo.t_CaseBack CHECK CONSTRAINT FK_CaseBack_RecordCaseBack
go
