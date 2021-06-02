USE AccountOMS
GO
SELECT f.CodeM,a.Account,m.Mes,c.id
--,CASE WHEN dd.TypeDiagnosis=1 THEN dd.DiagnosisCode ELSE NULL END AS DS1
--,CASE WHEN dd.TypeDiagnosis=3 THEN dd.DiagnosisCode ELSE NULL END AS DS2
--,CASE WHEN dd.TypeDiagnosis=4 THEN dd.DiagnosisCode ELSE NULL END AS DS3
,dd.DS1,dd.DS2,dd.DS3
,mm.MUSurgery,c.Age,p.rf_idV005 AS SexId,
CASE WHEN c.KD IN(1,2,3) THEN 1 WHEN c.kd>3 AND c.kd<8 THEN 8 WHEN c.KD IN(8,9,10) THEN 9 ELSE 10 END AS Los
,CASE WHEN ad.rf_idAddCretiria NOT LIKE 'fr%' THEN ad.rf_idAddCretiria ELSE NULL END AS Crit
,CASE WHEN ad.rf_idAddCretiria LIKE 'fr%' THEN ad.rf_idAddCretiria ELSE NULL END AS fraction
INTO #tStacionar
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
			AND m.TypeMES=2
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase							
					INNER JOIN dbo.t_RegisterPatient p ON
            r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
					INNER JOIN dbo.t_Meduslugi mm ON
            c.id=mm.rf_idCase			
					LEFT JOIN dbo.t_AdditionalCriterion ad ON
            c.id=ad.rf_idCase					
WHERE f.DateRegistration>'20200101' AND f.DateRegistration<GETDATE() AND a.ReportYear=2020 AND c.rf_idV006=1 AND m.TypeMES=2					

-------------------------составить комбинации ------------------------
SELECT *
FROM #tStacionar s 
WHERE NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprCSGRule2020 k 
				 WHERE k.code=s.mes and (ISNULL(k.DS1,s.DS1)=ISNULL(s.DS1,'bla') 
						or ISNULL(k.ds2,'bla')=ISNULL(s.ds2,'bla') OR ISNULL(k.ds3,'bla')=ISNULL(k.ds3,'bla')
						or ISNULL(s.MUSurgery,'bla')=ISNULL(k.MUSurgery,'bla') or ISNULL(k.SexId,s.SexId)=s.SexId 
						or s.los=ISNULL(k.los,s.los) AND ISNULL(s.Crit,'bla')=ISNULL(k.codeAdditionCriteria,'bla') 
						OR ISNULL(s.fraction,'bla')=ISNULL(k.fraction,'bla'))
						AND k.USL_OK=1
					)
ORDER BY s.id

GO
DROP TABLE #tStacionar