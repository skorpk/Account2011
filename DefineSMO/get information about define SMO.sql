USE RegisterCases
GO
SELECT c.id,i.rf_idIteration,z.rf_idZP1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
				  INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
				  INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
				  INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
			r.id=rp.rf_idRecordCase                
					INNER JOIN dbo.t_RegisterPatient p ON
			rp.rf_idRegisterPatient=p.id
			AND f.id=p.rf_idFiles	
					INNER JOIN dbo.t_RefCasePatientDefine rd ON
			c.id=rd.rf_idCase
			AND p.id=rd.rf_idRegisterPatient
					INNER JOIN dbo.t_CasePatientDefineIteration i ON
			rd.id=i.rf_idRefCaseIteration
					INNER JOIN dbo.t_CaseDefineZP1 z ON
			rd.id=z.rf_idRefCaseIteration		
WHERE f.DateRegistration>'20160101' AND f.CodeM='185905' AND a.NumberRegister IN(122,51) AND p.fam IN('Далаева','Абдулвадудова')