USE RegisterCases
GO
if(OBJECT_ID('usp_Test311',N'P')) is not null
	drop PROCEDURE dbo.usp_Test311
go
CREATE PROC dbo.usp_Test311
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #td FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'A00' AND 'T98'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'U%'

INSERT #tError
SELECT DISTINCT c.id,'311'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase					
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND p.rf_idV025 IN('1.0','1.1','1.2','1.3','3.0') AND c.rf_idV010<>28
AND NOT EXISTS(SELECT 1 FROM #td t WHERE t.DiagnosisCode=d.DS1)

INSERT #tError
SELECT DISTINCT c.id,'311'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase					
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND p.rf_idV025 ='2.6' AND d.DS1='Z%' AND c.rf_idV010=28

DROP TABLE #td

GO
GRANT EXECUTE ON usp_Test311 TO db_RegisterCase