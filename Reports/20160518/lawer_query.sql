USE RegisterCases
GO


;WITH cases
AS 
(
SELECT f.DateRegistration,f.CodeM,a.NumberRegister,a.DateRegister,c.idRecordCase,e.ErrorNumber,e.rf_idCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
					INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
			r.id=rp.rf_idRecordCase                  
					INNER JOIN dbo.t_RegisterPatient p ON
			rp.rf_idRegisterPatient=p.id
			AND f.id=p.rf_idFiles
					INNER JOIN dbo.t_ErrorProcessControl e ON
			c.id=e.rf_idCase
			AND f.id=e.rf_idFile                  								
WHERE f.CodeM='801934' AND f.DateRegistration>'20150701' AND f.DateRegistration<'20160101' AND a.ReportYear=2015
	AND p.Fam='Суздальская' AND p.IM='Людмила' AND p.BirthDay='19761209'
)
SELECT c.DateRegistration,c.CodeM,c.NumberRegister,c.DateRegister,c.idRecordCase,CAST(c.ErrorNumber AS VARCHAR(3))+' - '+e.DescriptionError
FROM cases c INNER JOIN OMS_NSI.dbo.sprAllErrors e ON
		c.ErrorNumber=e.Code 
			

				