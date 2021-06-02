USE RegisterCases
GO

CREATE TABLE dbo.t_DS_ONK_REAB(
	rf_idCase bigint NOT NULL,
	DS_ONK tinyint  NULL,
	Reab tinyint
) ON RegisterCases

GO 
ALTER TABLE dbo.t_DS_ONK_REAB  WITH CHECK ADD  CONSTRAINT FK_t_DS_ONK_REAB_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_DS_ONK_REAB CHECK CONSTRAINT FK_t_DS_ONK_REAB_Cases
GO
-----------------------------------------------------------------
CREATE TABLE dbo.t_ONK_SL(
	id INT IDENTITY(1,1) PRIMARY key NOT NULL,
	rf_idCase bigint NOT NULL,	  
	DS1_T tinyint NULL,
	rf_idN002 smallint NOT NULL,	
	rf_idN003 smallint NOT NULL,
	rf_idN004 smallint NOT NULL,
	rf_idN005 smallint NOT NULL,
	IsMetastasis tinyint NULL,
	ConsultationInfo TINYINT NULL, --переносится в t_ONK_SL	
	TotalDose decimal(5,2) null
) ON RegisterCases

GO 
ALTER TABLE dbo.t_ONK_SL  WITH CHECK ADD  CONSTRAINT FK_t_ONK_SL_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_ONK_SL CHECK CONSTRAINT FK_t_ONK_SL_Cases
GO
ALTER TABLE dbo.t_ONK_SL ADD DateConsultation DATE NULL

CREATE TABLE dbo.t_DiagnosticBlock(
	rf_idONK_SL int NOT NULL,	  
	TypeDiagnostic tinyint NOT NULL,
	CodeDiagnostic SMALLINT NOT NULL,
	ResultDiagnostic SMALLINT NOT NULL
) ON RegisterCases

GO 
ALTER TABLE dbo.t_DiagnosticBlock  WITH CHECK ADD  CONSTRAINT FK_t_DiagnosticBlock_ONK_SL FOREIGN KEY(rf_idONK_SL)
REFERENCES dbo.t_ONK_SL (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_DiagnosticBlock CHECK CONSTRAINT FK_t_DiagnosticBlock_ONK_SL
GO
ALTER TABLE t_DiagnosticBlock ADD DateDiagnostic date

CREATE TABLE dbo.t_Contraindications(
	rf_idONK_SL int NOT NULL,	  
	Code tinyint NOT NULL,
	DateContraindications date NOT NULL
) ON RegisterCases

GO 
ALTER TABLE dbo.t_Contraindications  WITH CHECK ADD  CONSTRAINT FK_t_Contraindications_ONK_SL FOREIGN KEY(rf_idONK_SL)
REFERENCES dbo.t_ONK_SL (id)
ON DELETE CASCADE
GO 
ALTER TABLE t_Contraindications CHECK CONSTRAINT FK_t_Contraindications_ONK_SL
GO
-------------------Meduslugi--------------------
CREATE TABLE dbo.t_DirectionMU(
	rf_idCase bigint NOT NULL,
	DirectionDate DATE NOT NULL,
	TypeDirection TINYINT NOT NULL,
	MethodStudy TINYINT NULL,
	DirectionMU VARCHAR(15) NULL,
) ON RegisterCases

GO 
CREATE TABLE dbo.t_ONK_USL(
	rf_idCase bigint NOT NULL,
	GUID_MU UNIQUEIDENTIFIER,	
	rf_idN013 TINYINT NOT NULL,
	TypeSurgery TINYINT NULL,	  
	TypeDrug TINYINT NULL,
	TypeCycleOfDrug TINYINT NULL,
	TypeRadiationTherapy TINYINT NULL	
) ON RegisterCases
GO 
ALTER TABLE dbo.t_Case ADD MSE TINYINT

ALTER TABLE dbo.t_Case ADD C_ZAB TINYINT

--------------------Type F---------------------
ALTER TABLE dbo.t_DispInfo ADD IsOnko TINYINT NULL
go
ALTER TABLE dbo.t_Prescriptions ADD id TINYINT NULL
GO
------------------------------------------------------------

GRANT INSERT,SELECT ON dbo.t_DS_ONK_REAB TO db_RegisterCase;
GRANT INSERT,SELECT ON dbo.t_ONK_SL TO db_RegisterCase;
GRANT INSERT,SELECT ON dbo.t_DiagnosticBlock TO db_RegisterCase;
GRANT INSERT,SELECT ON dbo.t_Contraindications TO db_RegisterCase;
GRANT INSERT,SELECT ON dbo.t_DirectionMU TO db_RegisterCase;
GRANT INSERT,SELECT ON dbo.t_ONK_USL TO db_RegisterCase;

/*
DROP TABLE  dbo.t_DS_ONK_REAB 
DROP TABLE  dbo.t_ONK_SL 
DROP TABLE  dbo.t_DiagnosticBlock 
DROP TABLE  dbo.t_Contraindications
DROP TABLE  dbo.t_DirectionMU 
DROP TABLE  dbo.t_ONK_USL

ALTER TABLE dbo.t_DispInfo DROP COLUMN IsOnko 
go
ALTER TABLE dbo.t_Prescriptions DROP COLUMN  id 
*/