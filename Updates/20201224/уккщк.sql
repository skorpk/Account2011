USE RegisterCases
GO
SELECT c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			a.rf_idFiles = f.id
					INNER JOIN dbo.t_RecordCase r ON
            a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
            c.rf_idRecordCase = r.id
WHERE a.ReportYear=2020 AND a.NumberRegister=254 AND r.ID_Patient='FBF4470F-5AD0-CDD3-3B6D-DA34E1DEF607'

SELECT *
FROM dbo.t_RefCasePatientDefine r INNER JOIN dbo.t_CaseDefineZP1Found z ON
				r.id=z.rf_idRefCaseIteration
WHERE rf_idCase IN(135176990,135176991)

SELECT *
FROM PolicyRegister.dbo.ZP1 WHERE ID IN(8682672,8682673)