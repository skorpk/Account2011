------изменить имя БД-----------
USE AccountOMS
GO
ALTER TABLE t_File ADD CountSluch INT NULL
go
DROP INDEX [IX_Account_idRecord] ON [dbo].[t_RegistersAccounts]
GO
ALTER TABLE dbo.t_RegistersAccounts ALTER COLUMN idRecord BIGINT NOT NULL;
GO
CREATE NONCLUSTERED INDEX [IX_Account_idRecord] ON [dbo].[t_RegistersAccounts]
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
ALTER TABLE dbo.t_Case ALTER COLUMN IsChildTariff BIT NULL
go
--ALTER TABLE dbo.t_Case ADD TypeDisp smallint NULL;
GO
--ALTER TABLE dbo.t_Case ADD IsCanselDisp tinyint NULL;
GO
ALTER TABLE dbo.t_Meduslugi ALTER COLUMN IsChildTariff BIT NULL
go
ALTER TABLE dbo.t_Meduslugi ALTER COLUMN DiagnosisCode CHAR(10) NULL
go
ALTER TABLE dbo.t_Meduslugi ADD IsNeedUsl TINYINT NULL;
go
ALTER TABLE dbo.t_RegisterPatient ADD TEL  VARCHAR(10) NULL
go
ALTER TABLE dbo.t_RegisterPatient ALTER COLUMN Fam NVARCHAR(40) NULL
go
ALTER TABLE dbo.t_RegisterPatient ALTER COLUMN Im NVARCHAR(40) NULL
go
ALTER TABLE dbo.t_RegisterPatient ALTER COLUMN Ot NVARCHAR(40) null



			                    