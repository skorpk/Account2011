USE RegisterCases
GO

SELECT fb.CodeM,fb.CodeM+'-'+l.NameS AS LPU ,CAST(rcb.NumberRegister AS VARCHAR(10))+'-'+CAST(rcb.PropertyNumberRegister AS CHAR(1)) AS NumberSP_TK,COUNT(recb.rf_idCase)
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							INNER JOIN dbo.t_CaseBack cp ON
			cp.rf_idRecordCaseBack = recb.id
							INNER JOIN dbo.t_RefCasePatientDefine d ON
            d.rf_idCase = recb.rf_idCase
			AND d.rf_idFiles=fb.rf_idFiles
							INNER JOIN dbo.t_CaseDefineZP1Found z ON
				d.id=z.rf_idRefCaseIteration
							INNER JOIN dbo.vw_sprT001 l ON
                 l.CodeM = fb.CodeM
where cp.TypePay=1 AND p.ENP IS NULL AND fb.DateCreate>'20200125'
GROUP BY fb.CodeM,fb.CodeM+'-'+l.NameS ,CAST(rcb.NumberRegister AS VARCHAR(10))+'-'+CAST(rcb.PropertyNumberRegister AS CHAR(1)) 
ORDER BY LPU