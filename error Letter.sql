USE AccountOMS
go
SET NOCOUNT ON
DECLARE @idFile INT,
		@Letter CHAR(1)

SELECT @idFile=id, @Letter=Letter FROM dbo.vw_getIdFileNumber WHERE CodeM='101001' AND NumberRegister=28 AND PrefixNumberRegister='34002' AND ReportYear=2013

SELECT DISTINCT a.Account,f.CodeM
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND f.DateRegistration>='20130101'
			AND f.DateRegistration<=GETDATE()
				 INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
			--AND a.rf_idFiles=@idFile
				 INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
			AND c.IsCompletedCase=1
				INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase								
				LEFT JOIN vw_sprMuWithParamAccount s ON
			m.MES=s.MU and AccountParam=@Letter 
WHERE s.MU IS NULL
ORDER BY f.CodeM
go