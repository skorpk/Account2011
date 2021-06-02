USE RegisterCases
GO
SELECT c.GUID_Case,cd.*
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
								inner JOIN AccountOMS.dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
								INNER JOIN AccountOMS.dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
								INNER JOIN dbo.t_Case c1 ON
				c.GUID_Case=c1.GUID_Case
								INNER JOIN dbo.t_RefCasePatientDefine rf ON
				c1.id=rf.rf_idCase
								INNER JOIN dbo.t_CasePatientDefineIteration z ON
				rf.id=z.rf_idRefCaseIteration   
								INNER JOIN dbo.t_CaseDefine cd ON
				rf.id=cd.rf_idRefCaseIteration                           
WHERE f.DateRegistration>'20160811' AND a.ReportYear=2016 AND a.ReportMonth=8 AND a.PropertyNumberRegister=2 AND a.rf_idSMO='34001'				                              
								 