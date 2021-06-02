USE RegisterCases
GO
if(OBJECT_ID('usp_Test312',N'P')) is not null
	drop PROCEDURE dbo.usp_Test312
go
CREATE PROC dbo.usp_Test312
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #td FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

INSERT #tError
SELECT DISTINCT c.id,'312'
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
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND p.rf_idV025 ='1.3' AND c.rf_idV004 NOT IN(19,41)

DROP TABLE #td

GO
GRANT EXECUTE ON usp_Test312 TO db_RegisterCase