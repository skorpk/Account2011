USE RegisterCases
GO
SELECT p.FAM,p.Im,p.Ot,p.BirthDay, cor.pid ,cor.FAM ,cor.IM ,cor.OT ,cor.BirthDay ,cor.TypeEquale
FROM dbo.vw_getIdFileNumber f INNER JOIN dbo.t_ErrorProcessControl e ON
			f.id=e.rf_idFile
							INNER JOIN dbo.t_Case c ON
			e.rf_idCase=c.id
							INNER JOIN dbo.t_RefRegisterPatientRecordCase r ON
			c.rf_idRecordCase=r.rf_idRecordCase
							INNER JOIN dbo.vw_RegisterPatient p ON
			r.rf_idRegisterPatient=p.id
			AND f.id=p.rf_idFiles
							INNER JOIN dbo.t_RefCasePatientDefine rd ON
			c.id=rd.rf_idCase
			AND f.id=rd.rf_idFiles
							INNER JOIN dbo.t_CaseDefine cd ON
			rd.id=cd.rf_idRefCaseIteration                          
							INNER JOIN dbo.t_Correction cor ON
			cd.id=cor.rf_idCaseDefine     
WHERE f.CodeM='125901' AND f.ReportYear=2017 AND e.ErrorNumber=57 AND f.NumberRegister=7 --AND p.BirthDay='19930608'
ORDER BY p.BirthDay