USE RegisterCases
GO
DECLARE @dtStart DATETIME='20160101',
		@year smallint=2016
;WITH cases
AS 
(
SELECT c.id,c.DateBegin,c.DateEnd,m.MES,e.ErrorNumber,c.rf_idV002, c.rf_idV006, p.Fam,p.Im, p.Ot,p.BirthDay,f.CodeM, ps.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.t_PatientSMO ps on
			r.id=ps.ref_idRecordCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase                  
					INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
			r.id=rp.rf_idRecordCase                  
					INNER JOIN dbo.t_RegisterPatient p ON
			rp.rf_idRegisterPatient=p.id
			AND f.id=p.rf_idFiles
					INNER JOIN dbo.t_ErrorProcessControl e ON
			c.id=e.rf_idCase
			AND f.id=e.rf_idFile                  
			AND e.ErrorNumber=62					
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<GETDATE() AND a.ReportYear=@year 
		AND m.MES IN ('2004005','2504005','2001005','2002005','2003005')
)
SELECT c.rf_idSMO, s.sNameS ,l.CodeM,l.NameS, c.Fam+' '+ISNULL(c.Im,'')+' '+ISNULL(c.Ot,'') AS FIO, c.BirthDay,c.DateBegin, c.DateEnd, c.MES
FROM cases c INNER JOIN OMS_NSI.dbo.sprAllErrors e ON
		c.ErrorNumber=e.Code 
			INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM    
			INNER JOIN dbo.vw_sprSMO s ON
	c.rf_idSMO=s.smocod      
ORDER BY s.smocod,l.CodeM, FIo