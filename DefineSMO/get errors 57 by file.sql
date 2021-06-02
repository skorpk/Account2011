USE RegisterCases
GO
SELECT f.rf_idFiles,f.id,
	   COUNT(CASE WHEN cp.TypePay=2 THEN 'OK' ELSE NULL END) AS IsBad	   
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack				
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth<3
		AND r.ReportYear=2018
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack							
				INNER JOIN dbo.t_PatientBack pb ON
		cb.id=pb.rf_idRecordCaseBack
WHERE f.DateCreate>'20180206' AND f.DateCreate<'20180206 05:00' AND EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE ErrorNumber=57 AND rf_idCase=cb.rf_idCase)
GROUP BY f.rf_idFiles,f.id
