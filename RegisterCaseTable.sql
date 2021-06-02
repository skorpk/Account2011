use RegisterCases
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_FileTested',N'U')) is not null
	drop table dbo.t_FileTested
go
create table dbo.t_FileTested
(
	id int identity(1,1) not null PRIMARY KEY,
	DateRegistration datetime not null CONSTRAINT DF_DateRegistrationFileTested DEFAULT (GETDATE()),
	[FileName] varchar(50) not null,
	UserName varchar(30) not null CONSTRAINT DF_UserName default (ORIGINAL_LOGIN())	
)
go
ALTER TABLE dbo.t_FileTested ADD ErrorDescription VARCHAR(250) null
GO

--ALTER TABLE dbo.t_FileTested ALTER COLUMN ErrorDescription NVARCHAR(250) null
GO
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_File',N'U')) is not null
	drop table dbo.t_File
go
create table dbo.t_File
(
	[GUID] uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE ,
	id int identity(1,1) not null PRIMARY KEY,
	DateRegistration datetime not null CONSTRAINT DF_DateRegistration DEFAULT (GETDATE()),
	FileVersion char(5) not null,
	DateCreate date not null,
	[FileNameHR] varchar(26) not null,
	[FileNameLR] varchar(26) not null,
	FileZIP varbinary(MAX) FILESTREAM
)
go
ALTER TABLE dbo.t_File ADD rf_idFileTested int not null
go
ALTER TABLE [dbo].[t_File] ADD  CONSTRAINT [DF_GUID_File]  DEFAULT (NEWSEQUENTIALID()) FOR [GUID]
go
ALTER TABLE dbo.t_File WITH CHECK ADD  CONSTRAINT FK_File_FileTested FOREIGN KEY(rf_idFileTested)
REFERENCES dbo.t_FileTested(id)
GO
ALTER TABLE dbo.t_File ADD CountSluch int null
GO
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegistersCase',N'U')) is not null
	drop table dbo.t_RegistersCase
go
create table dbo.t_RegistersCase
(
	rf_idFiles int not null CONSTRAINT FK_RegistersCases_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id),
	id int identity(1,1) not null,
	rf_idMO char(6) not null,
	ReportYear smallint not null CONSTRAINT CheckYear CHECK(ReportYear>YEAR(GETDATE())-1 and ReportYear<=YEAR(GETDATE())),
	ReportMonth tinyint not null CONSTRAINT CheckMonth CHECK(ReportMonth>0 and ReportMonth<13),
	NumberRegister int not null CONSTRAINT CheckNumber CHECK(NumberRegister>0),
	DateRegister date not null CONSTRAINT CheckRegisterDate CHECK(DateRegister<=GETDATE()) ,
	rf_idSMO char(5) null,
	AmountPayment decimal(15,2) not null,
	Comments varchar(250) null,
	AmountPaymentAccept decimal(11,2) null,
	AmountMEK decimal(15,2) null,
	AmountMEE decimal(15,2) null,
	AmountEKMP decimal(15,2) null,
	CONSTRAINT PK_RegisterCases_idFiles_idRegisterCases PRIMARY KEY CLUSTERED (id)
) 
go
alter table dbo.t_RegistersCase add idRecord int not null
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RecordCase',N'U')) is not null
	drop table dbo.t_RecordCase
go
create table dbo.t_RecordCase
(
	id int identity(1,1) not null,
	rf_idRegistersCase int not null CONSTRAINT FK_RecordCase_RegistersCase FOREIGN KEY(rf_idRegistersCase) REFERENCES dbo.t_RegistersCase(id),
	idRecord smallint not null,	
	IsNew bit,
	ID_Patient varchar(36) not null,
	rf_idF008 tinyint not null,
	SeriaPolis varchar(10) null,
	NumberPolis varchar(20) not null,
	NewBorn  char(9) not null,
	CONSTRAINT PK_RecordCase_idFiles_idRecordCase PRIMARY KEY CLUSTERED (id)
)
go
alter table t_RecordCase  add NPolisLen as len(NumberPolis)
go
alter table t_RecordCase add IsChild as (case when left(NewBorn,1)='0' then 0 else 1 end)
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_PatientSMO',N'U')) is not null
	drop table dbo.t_PatientSMO
go
create table dbo.t_PatientSMO
(
	ref_idRecordCase int not null,
	rf_idSMO char(5) null,
	OGRN char(15) null,
	OKATO char(5) null,
	Name nvarchar(100) null,
	CONSTRAINT FK_PatientSMO_Patient FOREIGN KEY(ref_idRecordCase) REFERENCES dbo.t_RecordCase(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_Case',N'U')) is not null
	drop table dbo.t_Case
go
create table dbo.t_Case
(
	id bigint identity(1,1) not null PRIMARY KEY,
	rf_idRecordCase int not null,
	idRecordCase int not null,
	GUID_Case uniqueidentifier not null ,
	rf_idV006 tinyint,
	rf_idV008 smallint,
	rf_idDirectMO char(6) null,
	HopitalisationType tinyint null,
	rf_idMO char(6) not null,
	rf_idSubMO char(6) null,
	rf_idDepartmentMO int null,
	rf_idV002 smallint not null,
	IsChildTariff bit not null,
	NumberHistoryCase nvarchar(50) not null,
	DateBegin date not null,
	DateEnd date not null,
	rf_idV009 smallint not null,
	rf_idV012 smallint not null,
	rf_idV004 int not null,
	rf_idDoctor char(16) null,
	IsSpecialCase tinyint null,
	rf_idV010 tinyint not null,
	AmountPayment decimal(15,2) not null CONSTRAINT CH_More_Equal_Zero CHECK(AmountPayment>=0),
	TypePay tinyint null,
	AmountPaymentAccept decimal(15,2) null,
	Comments nvarchar(250) null,
	Age int null,
	CONSTRAINT FK_Cases_Files FOREIGN KEY(rf_idRecordCase) REFERENCES dbo.t_RecordCase(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_Diagnosis',N'U')) is not null
	drop table dbo.t_Diagnosis
go
create table dbo.t_Diagnosis
(
	DiagnosisCode char(10),
	rf_idCase bigint not null,
	TypeDiagnosis tinyint not null,--- 1-Primary 2-Secondary 3-Accompanied
	CONSTRAINT FK_Diagnosis_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_MES',N'U')) is not null
	drop table dbo.t_MES
go
create table t_MES
(
	MES char(16),
	rf_idCase bigint not null,
	TypeMES tinyint not null ,--- 1-Primary 2-Secondary 
	Quantity decimal(5,2) null,
	Tariff decimal(15,2) null,
	CONSTRAINT FK_MES_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_ReasonPaymentCancelled',N'U')) is not null
	drop table dbo.t_ReasonPaymentCancelled
go
create table dbo.t_ReasonPaymentCancelled
(
	rf_idCase bigint not null,
	rf_idPaymentAccountCanseled tinyint not null,
	CONSTRAINT FK_ReasonPaymentCanseled_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_FinancialSanctions',N'U')) is not null
	drop table dbo.t_FinancialSanctions
go
create table dbo.t_FinancialSanctions
(
	rf_idCase bigint not null,
	Amount decimal(15,2) not null,
	TypeSanction tinyint not null,--1-MEK 2-MEE 3-EKMP
	CONSTRAINT FK_FinancialSanctions_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_Meduslugi',N'U')) is not null
	drop table dbo.t_Meduslugi
go
create table dbo.t_Meduslugi
(
	rf_idCase bigint not null,
	id int not null,
	GUID_MU uniqueidentifier not null,
	rf_idMO char(6) not null,
	rf_idSubMO char(6) null,
	rf_idDepartmentMO int null,
	rf_idV002 smallint not null,
	IsChildTariff bit not null,
	DateHelpBegin date not null,
	DateHelpEnd date not null,
	DiagnosisCode char(10) not null,
	MUCode varchar(16)not null,
	Quantity decimal(6,2) not null,
	Price decimal(15,2) not null,
	TotalPrice decimal(15,2) not null,
	rf_idV004 int not null,
	rf_idDoctor char(16) null,
	Comments nvarchar(250) null,
	CONSTRAINT FK_Meduslugi_Cases FOREIGN KEY(rf_idCase) REFERENCES dbo.t_Case(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegisterPatient',N'U')) is not null
	drop table dbo.t_RegisterPatient
go
create table t_RegisterPatient
(
	id int identity(1,1) not null PRIMARY KEY,
	rf_idFiles int not null CONSTRAINT FK_RegisterPatient_Files FOREIGN KEY(rf_idFiles) REFERENCES dbo.t_File(id),
	ID_Patient varchar(36) not null,
	Fam nvarchar(40) not null,
	Im nvarchar(40) not null,
	Ot nvarchar(40) null,
	rf_idV005 tinyint not null,
	BirthDay date not null,
	BirthPlace nvarchar(100) null	
)
go
--alter table dbo.t_RegisterPatient add rf_idRecordCase int
go
----------------------------22.01.2012-----------------------------------------------------------------------------------
if(OBJECT_ID('t_RefRegisterPatientRecordCase',N'U')) is not null
	drop table dbo.t_RefRegisterPatientRecordCase	
go
create table t_RefRegisterPatientRecordCase
(
	rf_idRegisterPatient int not null,	
	rf_idRecordCase int not null,
	CONSTRAINT FK_Ref_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id) ON DELETE CASCADE,
	CONSTRAINT FK_Ref_RecordCase FOREIGN KEY(rf_idRecordCase) REFERENCES dbo.t_RecordCase(id)
)
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegisterPatientAttendant',N'U')) is not null
	drop table dbo.t_RegisterPatientAttendant
go
create table t_RegisterPatientAttendant
(
	rf_idRegisterPatient int,
	Fam nvarchar(40) not null,
	Im nvarchar(40) not null,
	Ot nvarchar(40) not null,
	rf_idV005 tinyint not null,
	BirthDay date not null,
	CONSTRAINT FK_RegisterPatientAttendant_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_RegisterPatientDocument',N'U')) is not null
	drop table dbo.t_RegisterPatientDocument
go
create table t_RegisterPatientDocument
(
	rf_idRegisterPatient int,
	rf_idDocumentType char(2) null,
	SeriaDocument varchar(10) null,
	NumberDocument varchar(20) null,
	SNILS char(14) null,
	OKATO char(11) null,
	OKATO_Place char(11) null,
	Comments nvarchar(250) null,
	CONSTRAINT FK_RegisterPatientDocument_RegisterPatient FOREIGN KEY(rf_idRegisterPatient) REFERENCES dbo.t_RegisterPatient(id)
)
go
----------------------------------------------------------------------------------------------------------------
if(OBJECT_ID('t_XmlElement',N'U')) is not null
	drop table dbo.t_XmlElement
go
create table dbo.t_XmlElement
(
	id int identity(1,1) not null ,
	NameElement varchar(40) not null,
	Parent_id int null
)
go
insert t_XmlElement(NameElement, Parent_id)
values('ZGLV',null),('SCHET',null),('ZAP',null),('PACIENT',null),('SLUCH',null),('USL',null)
go
----1 - ZGLV
insert t_XmlElement(NameElement, Parent_id)
values('VERSION',1),('DATA',1),('FILENAME',1),('FILENAME1',1)
----2 - SCHET
insert t_XmlElement(NameElement, Parent_id)
values('CODE',2),('CODE_MO',2),('YEAR',2),('MONTH',2),('NSCHET',2),('DSCHET',2),('PLAT',2),('SUMMAV',2),('COMENTS',2),('SUMMAP',2),('SANK_MEK',2),('SANK_MEE',2),
		('SANK_EKMP',2)
----3 - ZAP
insert t_XmlElement(NameElement, Parent_id)
values('N_ZAP',3),('PR_NOV',3)
----4 - PACIENT
insert t_XmlElement(NameElement, Parent_id)
values('ID_PAC',4),('VPOLIS',4),('SPOLIS',4),('NPOLIS',4),('SMO',4),('SMO_OGRN',4),('SMO_OK',4),('SMO_NAM',4),('NOVOR',4)
----5 - SLUCH
insert t_XmlElement(NameElement, Parent_id)
values('IDCASE',5),('ID_C',5),('USL_OK',5),('VIDPOM',5),('NPR_MO',5),('EXTR',5),('LPU',5),('LPU_1',5),('PODR',5),('PROFIL',5),
	  ('DET',5),('NHISTORY',5),('DATE_1',5),('DATE_2',5),('DS0',5),('DS1',5),('DS2',5),('CODE_MES1',5),('CODE_MES2',5),('RSLT',5),
	  ('ISHOD',5),('PRVS',5),('IDDOKT',5),('OS_SLUCH',5),('IDSP',5),('ED_COL',5),('TARIF',5),('SUMV',5),('OPLATA',5),('SUMP',5),
	  ('REFREASON',5),('SANK_MEK',5),('SAN_MEE',5),('SAN_EKMP',5),('USL',5),('COMENTSL',5)
	  
----6 - USL
insert t_XmlElement(NameElement, Parent_id)
values('IDSERV',6),('ID_U',6),('LPU',6),('LPU_1',6),('PODR',6),('PROFIL',6),('DET',6),('DATE_IN',6),('DATE_OUT',6),('DS',6),
		('CODE_USL',6),('KOL_USL',6),('TARIF',6),('SUMV_USL',6),('PRVS',6),('CODE_MD',6),('COMENTU',6)
go
select @@IDENTITY
go
----88 - PERS
insert t_XmlElement(NameElement, Parent_id)
values('PERS',null)
go
insert t_XmlElement(NameElement, Parent_id)
values('ID_PAC',88),('FAM',88),('IM',88),('OT',88),('W',88),('DR',88),('FAM_P',88),('IM_P',88),('OT_P',88),('W_P',88),
	  ('DR_P',88),('MR',88),('DOCTYPE',88),('DOCSER',88),('DOCNUM',88),('SNILS',88),('OKATOG',88),('OKATOP',88),('COMENTP',88)
go


