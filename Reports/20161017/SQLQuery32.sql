USE RegisterCases
GO
SELECT v.Fam,v.Im,v.Ot,CAST(DATEADD(DAY,-2,cast(v.Dr AS datetime)) AS DATE) AS Dr
INTO #t
FROM (values('Исаева','Галина','Владимировна',32166),
('Попова','Оксана','Владимировна',29513),
('Бутенко','Алина','Михайловна',32282),
('Жигалина','Алена','Николаевна',26845),
('Кулинич','Людмила','Геннадиевна',28097),
('Ли','Лариса','Геннадьевна',30502),
('Лобарь','Ирина','Сергеевна',31502),
('Любиченко','Мария','Анатольевна',30523),
('Мокрая','Татьяна','Викторовна',30941),
('Прудентова','Анна','Сергеевна',30185),
('Чурзина','Татьяна','Вячеславовна',29519),
('Беспалова','Оксана','Викторовна',27836), 
('Высоцкая','Ольга','Анатольевна',28084),
('Маментьева','Наталья','Владимировна',28936),
('Крутских','Мария','Сергеевна',30833)) v(Fam,Im,Ot,DR) 


SELECT distinct v.*,r.id,f.FileNameHR,a.NumberRegister, ps.rf_idSMO,e.ErrorNumber,a.ReportMonth
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
		AND p.BirthDay=v.Dr
				LEFT JOIN dbo.t_ErrorProcessControl e ON
		c.id=e.rf_idCase
		AND f.id=e.rf_idFile              
WHERE a.ReportYear=2016 AND a.ReportMonth IN (6,7,8) AND f.DateRegistration>'20160101'	AND f.CodeM='801934' AND f.FileNameHR='HRM801934T34_1607002'--'HRM801934T34_1608001' /*HRM801934T34_1607002      */
--ORDER BY v.Fam,a.ReportMonth
GO
DROP TABLE #t