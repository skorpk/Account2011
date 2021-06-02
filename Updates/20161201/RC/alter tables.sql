------изменить имя БД-----------
USE RegisterCases
GO
DROP INDEX [IX_Seek_By_idRecord] ON [dbo].[t_RegistersCase]
GO
ALTER TABLE dbo.t_RegistersCase ALTER COLUMN idRecord BIGINT NOT NULL;
go
CREATE NONCLUSTERED INDEX [IX_Seek_By_idRecord2] ON [dbo].[t_RegistersCase]
(
	[idRecord] ASC
)
INCLUDE ( 	[rf_idFiles]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.t_PatientSMO ADD ENP VARCHAR(16) NULL;
go
ALTER TABLE dbo.t_PatientSMO ADD ST_OKATO VARCHAR(5) NULL;
go
ALTER TABLE dbo.t_Case ADD TypeTranslation TINYINT NULL;
go	   
ALTER TABLE dbo.t_Case ADD IsFirstDS TINYINT NULL;
go
ALTER TABLE dbo.t_Case ADD IsNeedDisp TINYINT NULL;
GO
ALTER TABLE dbo.t_File ADD TypeFile AS LEFT(FileNameHR,1) 


GO
ALTER TABLE dbo.t_Case ALTER COLUMN IsChildTariff BIT NULL
go
ALTER TABLE dbo.t_Meduslugi ALTER COLUMN IsChildTariff BIT NULL
go
ALTER TABLE dbo.t_Meduslugi ALTER COLUMN DiagnosisCode CHAR(10) NULL
go
ALTER TABLE dbo.t_Meduslugi ADD IsNeedUsl TINYINT NULL;
go
ALTER TABLE dbo.t_RegisterPatient ADD TEL  VARCHAR(10) NULL
go
ALTER TABLE dbo.t_RecordCaseBack ADD IdStep TINYINT
go
ALTER TABLE dbo.t_PatientBack ADD ENP VARCHAR(16) null
GO
CREATE NONCLUSTERED INDEX IX_DiagnosisGroup ON dbo.t_Diagnosis(DiagnosisCode,TypeDiagnosis) INCLUDE(rf_idCase) WITH (online=ON)
go

DROP INDEX [IX_IdFile_Personal_Inform] ON [dbo].[t_RegisterPatient]
GO
ALTER TABLE dbo.t_RegisterPatient ALTER COLUMN Fam NVARCHAR(40) NULL
go
ALTER TABLE dbo.t_RegisterPatient ALTER COLUMN Im NVARCHAR(40) NULL
go
ALTER TABLE dbo.t_RegisterPatient ALTER COLUMN Ot NVARCHAR(40) null
GO
CREATE NONCLUSTERED INDEX [IX_IdFile_Personal_Inform] ON [dbo].[t_RegisterPatient]
(
	[rf_idFiles] ASC,
	[rf_idRecordCase] ASC
)
INCLUDE ( 	[id],
	[Fam],
	[Im],
	[Ot],
	[rf_idV005],
	[BirthDay],
	[BirthPlace]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [RegisterCasesInsurer]
GO
			                    