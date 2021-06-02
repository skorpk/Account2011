USE RegisterCases
GO
--SELECT COUNT(DISTINCT p.ENP)
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
--			f.id=a.rf_idFiles
--					INNER JOIN dbo.t_RecordCase r ON
--			a.id=r.rf_idRegistersCase
--					INNER JOIN dbo.t_Case c ON
--			r.id=c.rf_idRecordCase
--					INNER JOIN dbo.t_PatientSMO p ON
--			r.id=p.ref_idRecordCase             
--					INNER JOIN dbo.t_RecordCaseBack rb ON
--			c.id=rb.rf_idCase
--					INNER JOIN dbo.t_PatientBack pb ON
--			rb.id=pb.rf_idRecordCaseBack     
--					INNER JOIN dbo.t_CaseBack cb ON
--			rb.id=cb.rf_idRecordCaseBack                  
--WHERE f.DateRegistration>'20170120' AND f.DateRegistration<GETDATE() AND a.ReportYear=2017 AND a.ReportMonth>0 AND a.ReportMonth<4
--		AND r.rf_idF008=3 AND p.rf_idSMO='34007' AND pb.rf_idSMO='34002' AND cb.TypePay=1 AND p.ENP	IS NOT null

SELECT r.*,p.enp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.ref_idRecordCase             
					INNER JOIN dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN dbo.t_PatientBack pb ON
			rb.id=pb.rf_idRecordCaseBack     
					INNER JOIN dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack                  
WHERE f.DateRegistration>'20170120' AND f.DateRegistration<GETDATE() AND a.ReportYear=2017 AND a.ReportMonth>0 AND a.ReportMonth<4
		AND r.rf_idF008=3 AND p.rf_idSMO='34007' AND pb.rf_idSMO='34002' AND cb.TypePay=1 AND p.ENP	<>r.NumberPolis