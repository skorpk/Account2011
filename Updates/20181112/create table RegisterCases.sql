USE RegisterCases
GO
if(OBJECT_ID('t_CompletedCase',N'U')) is not null
	drop table dbo.t_CompletedCase
go
CREATE TABLE dbo.t_CompletedCase(
	id int IDENTITY(1,1) NOT NULL,
	rf_idRecordCase	INT NOT NULL,
	idRecordCase bigint NOT NULL,
	GUID_ZSL uniqueidentifier NOT NULL,	
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	VB_P TINYINT NULL,
	HospitalizationPeriod SMALLINT NULL,
	AmountPayment DECIMAL(15,2),	
PRIMARY KEY CLUSTERED 
(
	id ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON RegisterCases
) ON RegisterCases
GO 
ALTER TABLE dbo.t_CompletedCase  WITH CHECK ADD  CONSTRAINT FK_CompCases_Patient FOREIGN KEY(rf_idRecordCase)
REFERENCES dbo.t_RecordCase (id)
ON DELETE CASCADE
GO
if(OBJECT_ID('t_Consultation',N'U')) is not null
	drop table dbo.t_Consultation
go
CREATE TABLE dbo.t_Consultation(
	rf_idCase BIGINT NOT NULL,
	PR_CONS TINYINT NOT NULL,
	DateCons DATE NULL
) ON RegisterCases
GO 
ALTER TABLE dbo.t_Consultation  WITH CHECK ADD  CONSTRAINT FK_Coonsultation_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO
if(OBJECT_ID('t_SLK',N'U')) is not null
	drop table dbo.t_SLK
go
CREATE TABLE dbo.t_SLK(
	rf_idCase BIGINT NOT NULL,
	SL_K TINYINT NOT NULL
) ON RegisterCases
GO 
ALTER TABLE dbo.t_SLK  WITH CHECK ADD  CONSTRAINT FK_SLK_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO

if(OBJECT_ID('t_DrugTherapy',N'U')) is not null
	drop table dbo.t_DrugTherapy
go
CREATE TABLE dbo.t_DrugTherapy(
	rf_idCase BIGINT NOT NULL,
	rf_idN013 TINYINT NOT NULL,
	rf_idV020 VARCHAR(6) NOT null,
	rf_idV024 VARCHAR(10) NOT null,
	DateInjection DATE NOT NULL
) ON RegisterCases
GO 
ALTER TABLE dbo.t_DrugTherapy  WITH CHECK ADD  CONSTRAINT FK_DrugTherapy_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO
---------------------------------------------------------
ALTER TABLE dbo.t_CompletedCase CHECK CONSTRAINT FK_CompCases_Patient
GO
ALTER TABLE t_DirectionMU ADD DirectionMO VARCHAR(6)
go
ALTER TABLE t_DiagnosticBlock ADD REC_RSLT TINYINT
go
ALTER TABLE dbo.t_ONK_SL ADD K_FR TINYINT
ALTER TABLE dbo.t_ONK_SL ADD WEI DECIMAL(5,2)
ALTER TABLE dbo.t_ONK_SL ADD HEI TINYINT
ALTER TABLE dbo.t_ONK_SL ADD BSA DECIMAL(3,2)
GO
ALTER TABLE dbo.t_ONK_USL ADD PPTR TINYINT
go
ALTER TABLE dbo.t_Case ADD KD SMALLINT
go
ALTER TABLE dbo.t_MES ADD IsCSGTag  TINYINT null
go
ALTER TABLE dbo.t_NextVisitDate ADD Period AS CAST(LEFT(convert(CHAR(8),DateVizit,112 ),6) AS INT)


