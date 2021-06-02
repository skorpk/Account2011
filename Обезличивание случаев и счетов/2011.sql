USE AccountOMS
GO
SELECT id INTO #tFile FROM dbo.t_File WHERE DateRegistration<'20120101'

UPDATE r SET r.SeriaPolis=NULL, r.NumberPolis=null
FROM dbo.t_RegistersAccounts a INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
WHERE EXISTS(SELECT * FROM #tFile WHERE id=a.rf_idFiles)

UPDATE p SET p.Fam =null,p.Im=null ,p.Ot=null ,p.BirthDay='19000101' ,p.BirthPlace=null 
--SELECT  p.*
FROM dbo.t_RegisterPatient p INNER JOIN #tFile f ON
			p.rf_idFiles=f.id
UPDATE pd SET pd.SeriaDocument=null , pd.NumberDocument=null ,pd.SNILS=null ,pd.OKATO=null ,pd.OKATO_Place=null
--SELECT  pd.*
FROM dbo.t_RegisterPatient p INNER JOIN dbo.t_RegisterPatientDocument pd ON
			p.id=pd.rf_idRegisterPatient
WHERE EXISTS(SELECT * FROM #tFile WHERE id=p.rf_idFiles)

UPDATE ad SET ad.Fam=null, ad.Im=null ,ad.Ot=null ,ad.BirthDay=NULL
--SELECT  pd.*
FROM dbo.t_RegisterPatient p INNER JOIN dbo.t_RegisterPatientAttendant ad ON
			p.id=ad.rf_idRegisterPatient
WHERE EXISTS(SELECT * FROM #tFile WHERE id=p.rf_idFiles)
GO
DROP TABLE #tFile