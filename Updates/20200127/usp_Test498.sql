USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test498',N'P')) is not null
	drop PROCEDURE dbo.usp_Test498
go
CREATE PROC dbo.usp_Test498
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'


insert #tError
SELECT DISTINCT c.id,498
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'							 
			INNER JOIN dbo.t_Meduslugi m ON
        m.rf_idCase = c.id
			INNER JOIN vw_sprMU mm ON
        mm.MU=m.MUCode			
			INNER JOIN dbo.t_Diagnosis d ON
         d.rf_idCase = c.id
			INNER JOIN #tDS1 dd ON
          dd.DiagnosisCode = d.DiagnosisCode
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV010=28 AND d.TypeDiagnosis=1 AND mm.MUGroupCode=60 AND mm.MUUnGroupCode =8
	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL dd INNER JOIN dbo.t_DiagnosticBlock d1 ON
									dd.id=d1.rf_idONK_SL
					WHERE dd.rf_idCase=c.id AND d1.TypeDiagnostic IS NOT null AND d1.CodeDiagnostic IS NOT NULL
						AND d1.ResultDiagnostic IS NOT NULL and DateDiagnostic IS NOT NULL AND d1.REC_RSLT IS NOT null)


DROP TABLE #tDS1
GO
GRANT EXECUTE ON usp_Test498 TO db_RegisterCase