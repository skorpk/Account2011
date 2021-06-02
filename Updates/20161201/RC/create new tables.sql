USE RegisterCases
GO
-------------Disability-------------------------
IF OBJECT_ID('t_Disability',N'U') IS NOT NULL
	DROP TABLE t_Disability
GO
CREATE TABLE t_Disability
(
	ref_idRecordCase INT NOT NULL,
	TypeOfGroup TINYINT NULL,
	DateDefine DATE,
	rf_idReasonDisability TINYINT,
	Diagnosis varchar(10)
) ON [RegisterCasesError]
go
ALTER TABLE t_Disability  WITH CHECK ADD  CONSTRAINT FK_Disability_RecordCases FOREIGN KEY(ref_idRecordCase)
REFERENCES dbo.t_RecordCase (id)
ON DELETE CASCADE
GO															 
ALTER TABLE t_Disability CHECK CONSTRAINT FK_Disability_RecordCases
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
) ON [RegisterCasesError]
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

WITH cte
AS
(
SELECT ROW_NUMBER() OVER(PARTITION BY rf_idRefCaseIteration ORDER BY DateDefine) AS id, rf_idRefCaseIteration, pid 
FROM dbo.t_CaseDefine
)
delete FROM cte WHERE id>1
go
---------------------------------------------------------------------------------------------------
CREATE TABLE dbo.t_CaseDefineNew
(	
	id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	rf_idRefCaseIteration bigint NOT NULL,
	DateDefine datetime NOT NULL,
	PID int NULL,
	UniqueNumberPolicy varchar(20) NULL,
	IsDefined bit NOT NULL,
	SMO varchar(5) NULL,
	SPolicy varchar(20) NULL,
	NPolcy varchar(20) NULL,
	RN varchar(11) NULL,
	rf_idF008 tinyint NULL,
	UNumberPolicy  AS (case when rf_idF008=(1) then coalesce(UniqueNumberPolicy,coalesce(rtrim(SPolicy),'')+NPolcy)  end),
	AttachCodeM char(6) NULL,
	idStep tinyint NULL
) ON RegisterCasesBack 
GO
INSERT dbo.t_CaseDefineNEW( rf_idRefCaseIteration , DateDefine , PID ,UniqueNumberPolicy ,IsDefined ,SMO ,SPolicy ,NPolcy ,RN ,rf_idF008 ,AttachCodeM,idStep)
SELECT  rf_idRefCaseIteration ,DateDefine ,PID ,UniqueNumberPolicy ,IsDefined ,SMO ,SPolicy ,NPolcy ,RN ,rf_idF008 ,AttachCodeM,9 
FROM dbo.t_CaseDefine
go		 
EXEC sys.sp_rename @objname = N't_CaseDefine',@newname ='t_CaseDefineOLD'
go
EXEC sys.sp_rename @objname = N't_CaseDefineNew',@newname ='t_CaseDefine'
go
DROP TABLE dbo.t_CaseDefineOLD
go
ALTER TABLE dbo.t_CaseDefine  WITH CHECK ADD  CONSTRAINT FK_CaseDefine_RefCaseIteration FOREIGN KEY(rf_idRefCaseIteration)
REFERENCES dbo.t_RefCasePatientDefine (id)
ON DELETE CASCADE
GO
ALTER TABLE dbo.t_CaseDefine CHECK CONSTRAINT FK_CaseDefine_RefCaseIteration
GO		   
---------------------------------------------------------------------------------------------------
go
IF OBJECT_ID('t_Correction',N'U') IS NOT NULL
	DROP TABLE t_Correction
GO
CREATE TABLE t_Correction
(
	rf_idCaseDefine INT NOT NULL,
	pid INT NOT NULL,
	FAM VARCHAR(40),
	IM VARCHAR(40),
	OT VARCHAR(40),
	BirthDay date
) ON RegisterCasesInsurer
go
ALTER TABLE t_Correction WITH CHECK ADD  CONSTRAINT [FK_Correction_CaseDefine] FOREIGN KEY(rf_idCaseDefine)
REFERENCES t_CaseDefine ([id])
ON DELETE CASCADE
GO
ALTER TABLE t_Correction CHECK CONSTRAINT [FK_Correction_CaseDefine]
go
CREATE VIEW vw_CasePatientDefine
as
SELECT rf.id,rf_idCase, rf.rf_idRegisterPatient,idStep
FROM t_RefCasePatientDefine rf INNER join t_CaseDefine c1 on
					rf.id=c1.rf_idRefCaseIteration
GO
GRANT SELECT ON vw_CasePatientDefine TO db_RegisterCase 
----------Внимание дать права на новые таблицы---------------
