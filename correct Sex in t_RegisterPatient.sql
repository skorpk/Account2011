USE AccountOMS
go

SELECT p.id,p.Fam,p.Im,p.Ot,p.BirthDay,p.Sex
INTO #t
FROM t_File f INNER JOIN dbo.t_RegisterPatient p ON
			f.id=p.rf_idFiles
				INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
WHERE f.DateRegistration>'20140101'	AND a.Letter IN ('O')


--SELECT t1.*,t2.Sex,t2.id
--FROM #t t1 INNER JOIN #t t2 ON
--		t1.Fam=t2.Fam
--		AND t1.Im=t2.Im
--		AND t1.Ot=t2.Ot
--		AND t1.BirthDay = t2.BirthDay
--		AND t1.Sex <> t2.Sex
		
--DROP TABLE tmp_PeopleSex		
SELECT p.id,CASE WHEN pid.W=1 THEN 'Ì' ELSE 'Æ' END AS Sex
INTO tmp_PeopleSex
FROM t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
				INNER JOIN dbo.t_Case c ON 
			r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_Case_PID_ENP p1 ON
			c.id=p1.rf_idCase
				INNER JOIN PolicyRegister.dbo.PEOPLE pid ON
			p1.PID=pid.ID 		
WHERE f.DateRegistration>'20140101' AND a.Letter='O'

--SELECT * FROM #t1 WHERE id IN (29734147,28438781)
GO
DROP TABLE #t
DROP TABLE #t1