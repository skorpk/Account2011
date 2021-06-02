USE RegisterCases
GO
--SELECT *
--FROM dbo.vw_getIdFileNumber WHERE id=127184

--SELECT *
--FROM PolicyRegister.dbo.zp1 WHERE id=7262431

INSERT dbo.t_RefCasePatientDefine( rf_idCase ,rf_idRegisterPatient ,rf_idFiles )
SELECT c.id, rr.rf_idRegisterPatient,f.id
FROM t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
				INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
				INNER JOIN dbo.t_RefRegisterPatientRecordCase rr on
			r.id=rr.rf_idRecordCase
WHERE f.id=127184 AND NOT EXISTS(SELECT * FROM dbo.t_RefCasePatientDefine WHERE rf_idCase=c.id)