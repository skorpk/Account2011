USE [RegisterCases]
GO
create PROC [dbo].[usp_Test483]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

SELECT DiagnosisCode
INTO #tDS
FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%' OR DiagnosisCode LIKE 'D0%'

insert #tError
SELECT DISTINCT c.id,483
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20191101'
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase 		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV009=315 
	AND EXISTS(
				SELECT 1 FROM dbo.t_DS_ONK_REAB dd WHERE dd.rf_idCase=c.id AND dd.DS_ONK=1
				UNION ALL
				SELECT 1 FROM #tDS ds WHERE ds.DiagnosisCode=d.DS1
				)
	AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id )

GO
GRANT EXECUTE ON usp_Test483 TO db_RegisterCase
go

