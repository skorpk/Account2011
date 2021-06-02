USE RegisterCases
GO
if(OBJECT_ID('usp_Test_Diag',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_Diag
go
CREATE PROC dbo.usp_Test_Diag
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,'006F.00.0430'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
where a.rf_idFiles=@idFile  AND d.TypeDiagnosis=1 AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND d.DiagnosisCode=dd.DiagnosisCode AND d.TypeDiagnosis IN(3,4)
															 UNION ALL
															 SELECT 1 FROM dbo.t_DS2_Info ds WHERE ds.rf_idCase=c.id AND ds.DiagnosisCode=d.DiagnosisCode )


INSERT #tError
SELECT DISTINCT c.id,'006F.00.0440'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.TypeDiagnosis=3 
	AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND dd.TypeDiagnosis=4 AND dd.DiagnosisCode=d.DiagnosisCode)

--Если DS like 'P%', то Age(количество полных лет)=0  
CREATE TABLE #t(errorVode VARCHAR(20),TypeDiagnosis TINYINT)

INSERT #t(errorVode,TypeDiagnosis) VALUES('003K.00.0590',1),('003K.00.0600',3),('003K.00.0610',4)

INSERT #tError
SELECT DISTINCT c.id,t.errorVode
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
				JOIN #t t ON
         d.TypeDiagnosis=t.TypeDiagnosis
where a.rf_idFiles=@idFile AND c.Age>0 AND d.DiagnosisCode LIKE 'P%'

INSERT #tError
SELECT DISTINCT c.id,'003K.00.0610'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_DS2_Info d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'									
where a.rf_idFiles=@idFile AND c.Age>0 AND d.DiagnosisCode LIKE 'P%'

DROP TABLE #t
GO
GRANT EXECUTE ON usp_Test_Diag TO db_RegisterCase