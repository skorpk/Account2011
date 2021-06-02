USE RegisterCases 
GO
DECLARE @case AS TABLE (id BIGINT,rf_idFile int)

DECLARE @idFileBack INT,
		@idFile int

SELECT @idFile=rf_idFiles,@idFileBack=idFileBack FROM dbo.vw_getFileBack WHERE CodeM='111008' AND NumberRegister=3 AND ReportYear=2015

INSERT @case( id, rf_idFile )
SELECT DISTINCT c.id,f.id
FROM t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN dbo.t_RecordCaseBack rb ON
		c.id=rb.rf_idCase									
WHERE f.CodeM='111008' AND a.ReportYear=2015 AND m.MES LIKE '2300034'  AND f.DateRegistration>'20150101'

SELECT * FROM @case


BEGIN TRANSACTION

--INSERT dbo.t_ErrorProcessControl( DateRegistration ,ErrorNumber ,rf_idCase, rf_idFile )
--SELECT GETDATE(), 65, id ,rf_idFile FROM @case
SELECT @@ROWCOUNT

DELETE FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile AND ErrorNumber=65
SELECT @@ROWCOUNT
SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile

UPDATE c SET c.TypePay=1
from dbo.t_RecordCaseBack r INNER JOIN dbo.t_CaseBack c ON
				r.id=c.rf_idRecordCaseBack
							INNER JOIN @case i ON
				r.rf_idCase=i.id
SELECT @@ROWCOUNT				


select upper(c.GUID_Case) as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id						
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
				AND e.rf_idFile=@idFile
where rf_idFilesBack=@idFileBack
group by c.GUID_Case,e.ErrorNumber


COMMIT

