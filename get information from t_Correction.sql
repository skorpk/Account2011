USE RegisterCases
GO
SELECT cor.*,rd.rf_idRegisterPatient,cd.PID 
FROM dbo.t_Case c INNER JOIN dbo.t_RefCasePatientDefine rd ON
			c.id=rd.rf_idCase
					INNER JOIN dbo.t_CaseDefine cd ON
			rd.id=cd.rf_idRefCaseIteration
					INNER JOIN dbo.t_Correction cor ON
			cd.id=cor.rf_idCaseDefine                  
WHERE c.GUID_Case='D329545B-E0BD-4AC7-A86C-DAB0716B25B7'

SELECT *
FROM dbo.t_RegisterPatient WHERE id=69599435			                    