USE RegisterCases
GO
SELECT v.Fam,v.Im,v.Ot--,CAST(DATEADD(DAY,-2,cast(v.Dr AS datetime)) AS DATE) AS Dr
INTO #t
FROM (VALUES('Гребенкина','Людмила','Валерьевна'),
('Космынина','Евгения','Николаевна'),
('Полях','Яна','Вячеславовна')) v(Fam,Im,Ot) 


SELECT distinct v.*,r.id,f.DateRegistration,a.ReportMonth,a.NumberRegister, ps.rf_idSMO,pb.rf_idSMO AS codeSMO,e.ErrorNumber,a.ReportMonth,cb.TypePay
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
				INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
		r.id=rp.rf_idRecordCase
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
				INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.ref_idRecordCase              
				INNER JOIN dbo.t_RegisterPatient p ON
		rp.rf_idRegisterPatient=p.id
		AND p.rf_idFiles=f.id
				inner JOIN #t v on
		p.Fam=v.Fam
		AND p.Im=v.IM
		AND p.Ot=v.Ot
		--AND p.BirthDay=v.Dr
				INNER JOIN dbo.t_RecordCaseBack rb ON
		c.id=rb.rf_idCase
				INNER JOIN dbo.t_RegisterCaseBack rr ON
		rb.rf_idRegisterCaseBack=rr.id              
				INNER JOIN dbo.t_FileBack fb ON 
		rr.rf_idFilesBack=fb.id
				INNER JOIN dbo.t_CaseBack cb ON
		rb.id=cb.rf_idRecordCaseBack
				INNER JOIN dbo.t_PatientBack pb ON
		rb.id=pb.rf_idRecordCaseBack              
				LEFT JOIN dbo.t_ErrorProcessControl e ON
		c.id=e.rf_idCase
		AND f.id=e.rf_idFile              
WHERE a.ReportYear=2019 /*AND a.ReportMonth =10*/ AND f.DateRegistration>'20190101'	AND f.CodeM='801934' 
--ORDER BY v.Fam,a.ReportMonth
GO
DROP TABLE #t