USE AccountOMS
go
SET NOCOUNT ON
--SELECT distinct ID_Patient,FileNameHR,DateRegistration
--FROM (
--SELECT p.rf_idRecordCasePatient,r.ID_Patient,f.FileNameHR,f.DateRegistration
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
--			f.id=a.rf_idFiles
--				INNER JOIN dbo.t_RecordCasePatient r ON
--			a.id=r.rf_idRegistersAccounts
--				 INNER JOIN dbo.t_PatientSMO p ON
--			r.id=p.rf_idRecordCasePatient
--WHERE f.DateRegistration>'20130101' AND a.ReportYear=2013
--GROUP BY p.rf_idRecordCasePatient,r.ID_Patient,f.FileNameHR,f.DateRegistration
--HAVING COUNT(*)>1
--		) t
--ORDER BY DateRegistration

BEGIN TRANSACTION

DELETE FROM dbo.t_PatientSMO
FROM dbo.t_PatientSMO p INNER JOIN (VALUES(14793295,'12000'),(14793290,'46000'),(14793282,'12000'),(15864359,'12000'),(15864362,'12000'),
					(15864360,'57000'),(15864361,'57000'),(16137519,'03000'),(16137524,'79000'),(16137522,'03000'),
					(16137520,'03000'),(16137523,'79000'),(16154773,'12000'),(16154774,'85000')) t(id,OKATO) ON
					p.rf_idRecordCasePatient=t.ID
					AND p.OKATO<>t.OKATO
SELECT * 
FROM dbo.t_PatientSMO p INNER JOIN (VALUES(14793295,'12000'),(14793290,'46000'),(14793282,'12000'),(15864359,'12000'),(15864362,'12000'),
					(15864360,'57000'),(15864361,'57000'),(16137519,'03000'),(16137524,'79000'),(16137522,'03000'),
					(16137520,'03000'),(16137523,'79000'),(16154773,'12000'),(16154774,'85000')) t(id,OKATO) ON
					p.rf_idRecordCasePatient=t.ID
					AND p.OKATO<>t.OKATO
					
SELECT * 
FROM dbo.t_PatientSMO p INNER JOIN (VALUES(14793295,'12000'),(14793290,'46000'),(14793282,'12000'),(15864359,'12000'),(15864362,'12000'),
					(15864360,'57000'),(15864361,'57000'),(16137519,'03000'),(16137524,'79000'),(16137522,'03000'),
					(16137520,'03000'),(16137523,'79000'),(16154773,'12000'),(16154774,'85000')) t(id,OKATO) ON
					p.rf_idRecordCasePatient=t.ID
					--AND p.OKATO<>t.OKATO					
COMMIT

go