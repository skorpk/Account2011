USE RegisterCases
GO
SELECT f.DateRegistration,z.*
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
			INNER JOIN t_RefRegisterPatientRecordCase r1 ON
		r.id=r1.rf_idRecordCase
			INNER JOIN dbo.t_RegisterPatient p ON
		r1.rf_idRegisterPatient=p.id
			INNER JOIN dbo.t_RefCasePatientDefine rd ON
		c.id=rd.rf_idCase		
			INNER JOIN dbo.t_CaseDefineZP1Found z ON
		rd.id=z.rf_idRefCaseIteration
WHERE f.DateRegistration>'20170101' AND a.ReportYear=2017 AND a.NumberRegister=6 AND f.CodeM='255627'
AND p.Fam='Гусейнов'

SELECT f.DateRegistration,z.*
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
			INNER JOIN t_RefRegisterPatientRecordCase r1 ON
		r.id=r1.rf_idRecordCase
			INNER JOIN dbo.t_RegisterPatient p ON
		r1.rf_idRegisterPatient=p.id
			INNER JOIN dbo.t_RefCasePatientDefine rd ON
		c.id=rd.rf_idCase		
			INNER JOIN dbo.t_CaseDefineZP1 z ON
		rd.id=z.rf_idRefCaseIteration
WHERE f.DateRegistration>'20170101' AND a.ReportYear=2017 AND a.NumberRegister=6 AND f.CodeM='255627'
AND p.Fam='Гусейнов'