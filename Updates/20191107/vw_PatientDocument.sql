USE RegisterCases
GO
CREATE VIEW vw_PatientDocument
as
SELECT r.rf_idRecordCase,p.rf_idFiles,p.ID_Patient
			, pa.rf_idRegisterPatient,
             pa.rf_idDocumentType,
             pa.SeriaDocument,
             pa.NumberDocument,           
             pa.DOCDATE,
             pa.DOCORG
	FROM t_RegisterPatient p INNER JOIN t_RefRegisterPatientRecordCase r ON
					p.id=r.rf_idRegisterPatient
							LEFT JOIN dbo.t_RegisterPatientDocument pa ON
			p.id=pa.rf_idRegisterPatient
GO
GRANT SELECT ON vw_PatientDocument TO db_RegisterCase