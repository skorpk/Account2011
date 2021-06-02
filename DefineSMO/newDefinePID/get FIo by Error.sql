USE RegisterCases
GO
DECLARE @idFile INT

SELECT @idFile=id
FROM dbo.vw_getIdFileNumber WHERE CodeM='351001' AND ReportYear=2018 AND NumberRegister=59

SELECT DISTINCT c.GUID_Case, p.Fam ,p.Im,p.Ot, p.BirthDay, e.ErrorNumber
FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_Case c ON
				e.rf_idCase=c.id
								INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
				c.rf_idRecordCase=rp.rf_idRecordCase
								INNER JOIN dbo.t_RegisterPatient p ON
				rp.rf_idRegisterPatient=p.id
				AND e.rf_idFile=p.rf_idFiles
WHERE e.rf_idFile=@idFile