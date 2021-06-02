USE RegisterCases
GO

SELECT *
FROM dbo.vw_getFileBack WHERE CodeM='165310' AND ReportYear=2020 AND NumberRegister=4515 AND PropertyNumberRegister=2

SELECT DISTINCT fb.id,fb.DateCreate,fb.FileNameHRBack
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
					INNER JOIN t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
					INNER JOIN dbo.t_CaseBack cb ON
             cb.rf_idRecordCaseBack = recb.id
where fb.DateCreate>'20200124' AND p.ENP IS NULL AND cb.TypePay=1

SELECT p.*,z.UniqueNumberPolicy
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
					INNER JOIN t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
					INNER JOIN dbo.t_CaseBack cb ON
             cb.rf_idRecordCaseBack = recb.id
					INNER JOIN dbo.t_RefCasePatientDefine rf ON
             rf.rf_idCase = recb.rf_idCase
					INNER JOIN dbo.t_CaseDefineZP1Found z ON
             rf.id=z.rf_idRefCaseIteration
where fb.DateCreate>'20200124' AND p.ENP IS NULL AND cb.TypePay=1 AND fb.id IN(297687,297697)
/*
BEGIN TRANSACTION
UPDATE dbo.t_PatientBack SET ENP='3450530869000013' WHERE rf_idRecordCaseBack=119719062

commit
*/