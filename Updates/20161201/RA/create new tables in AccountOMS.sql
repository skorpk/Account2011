USE AccountOMS
GO
-------------Disability-------------------------
IF OBJECT_ID('t_Disability',N'U') IS NOT NULL
	DROP TABLE t_Disability
GO
CREATE TABLE t_Disability
(
	rf_idRecordCasePatient INT NOT NULL,
	TypeOfGroup TINYINT NOT NULL,
	DateDefine DATE,
	rf_idReasonDisability TINYINT,
	Diagnosis varchar(10)
) 
go
ALTER TABLE t_Disability  WITH CHECK ADD  CONSTRAINT FK_Disability_RecordCasesPatient FOREIGN KEY(rf_idRecordCasePatient)
REFERENCES dbo.t_RecordCasePatient (id)
ON DELETE CASCADE
GO															 
ALTER TABLE t_Disability CHECK CONSTRAINT FK_Disability_RecordCasesPatient
GO
------------------------Talon----------------
IF OBJECT_ID('t_SlipOfPaper',N'U') IS NOT NULL
	DROP TABLE t_SlipOfPaper
GO
CREATE TABLE t_SlipOfPaper
(
	rf_idCase BIGINT NOT NULL,
	GetDatePaper DATE,
	DateHospitalization date
)
go
ALTER TABLE t_SlipOfPaper  WITH CHECK ADD  CONSTRAINT FK_SlipOfPaper_Cases FOREIGN KEY(rf_idCase)
REFERENCES dbo.t_Case (id)
ON DELETE CASCADE
GO															 
ALTER TABLE t_SlipOfPaper CHECK CONSTRAINT FK_SlipOfPaper_Cases
GO
IF OBJECT_ID('t_ReliabilityPatient',N'U') IS NOT NULL
	DROP TABLE t_ReliabilityPatient
GO
CREATE TABLE t_ReliabilityPatient
(
	[rf_idRegisterPatient] INT,
	TypeReliability TINYINT,
	IsAttendant BIT --1 указывается для пациента и 2 для сопровождающего лица
)
go

IF OBJECT_ID('t_DispInfo',N'U') IS NOT NULL
	DROP TABLE t_DispInfo
GO
CREATE TABLE t_DispInfo
(
	rf_idCase BIGINT NOT NULL,
	TypeDisp VARCHAR(3) NOT NULL,
	IsMobileTeam BIT NOT NULL,
	TypeFailure TINYINT NOT NULL
)
go

IF OBJECT_ID('t_DS2_Info',N'U') IS NOT NULL
	DROP TABLE t_DS2_Info
GO
CREATE TABLE t_DS2_Info
(
	rf_idCase BIGINT,
	DiagnosisCode VARCHAR(10) NOT NULL,
	IsFirst BIT,
	IsNeedDisp tinyint
)
go
IF OBJECT_ID('t_Prescriptions',N'U') IS NOT NULL
	DROP TABLE t_Prescriptions
GO
CREATE TABLE t_Prescriptions
(
	rf_idCase BIGINT NOT null,
	NAZR TINYINT NOT NULL,
	rf_idV015 SMALLINT,
	TypeExamination TINYINT,
	rf_dV002 SMALLINT,
	rf_idV020 SMALLINT
)
go
---------------------------------------------------------------------------------------------------
