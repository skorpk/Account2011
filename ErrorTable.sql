use RegisterCases
go
if(OBJECT_ID('t_FileError',N'U')) is not null
	drop table dbo.t_FileError
go
create table dbo.t_FileError
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFileTested int not null CONSTRAINT FK_FileError_Files FOREIGN KEY(rf_idFileTested) REFERENCES dbo.t_FileTested(id),
	FileNameP varchar(26) not null,
	DateCreate datetime not null CONSTRAINT DF_DateCreate DEFAULT (GETDATE())	
)
go
if(OBJECT_ID('t_FileNameError',N'U')) is not null
	drop table dbo.t_FileNameError
go
create table dbo.t_FileNameError
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFileError int not null CONSTRAINT FK_FileName_FileError FOREIGN KEY(rf_idFileError) REFERENCES dbo.t_FileError(id),
	[FileName] varchar(26) not null
)
go
if(OBJECT_ID('t_Error',N'U')) is not null
	drop table dbo.t_Error
go
create table dbo.t_Error
(
	rf_idFileNameError int not null CONSTRAINT FK_Error_FileNameError FOREIGN KEY(rf_idFileNameError) REFERENCES dbo.t_FileNameError(id),
	rf_idF012 smallint not null,
	rf_idXMLElement int null,
	rf_idGuidFieldError varchar(40) null,
	ErrorTagAlter varchar(40),
	ErrorParentTagAlter varchar(40),
	Comments nvarchar(250) null	
)
go
--таблица для фиксации ошибок на этапе техн.контроля
if(OBJECT_ID('t_ErrorProcessControl',N'U')) is not null
	drop table dbo.t_ErrorProcessControl
go
create table t_ErrorProcessControl
(
	DateRegistration datetime not null default getdate(),
	ErrorNumber smallint not null,
	rf_idFile int not null,
	rf_idCase bigint not null,
	GUID_MU uniqueidentifier null
)
GO