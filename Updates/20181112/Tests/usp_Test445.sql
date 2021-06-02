USE [RegisterCases]
GO

if OBJECT_ID('usp_Test445',N'P') is not NULL
	DROP PROCEDURE usp_Test445
GO
create PROC dbo.usp_Test445
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,445
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'	
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.HospitalizationPeriod IS null AND c.rf_idV006<3 AND c.rf_idV010<>4

;WITH cteKD
AS(
SELECT r.id,cc.HospitalizationPeriod, SUM(c.KD) AS KD
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'	
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.HospitalizationPeriod IS NOT NULL AND c.rf_idV010<>4 
GROUP BY r.id,cc.HospitalizationPeriod
)
INSERT #tError
SELECT c.id,445
FROM cteKD k INNER JOIN dbo.t_Case c ON
		k.id=c.rf_idRecordCase
WHERE k.KD<>k.HospitalizationPeriod

GO
GRANT EXECUTE ON usp_Test445 TO db_RegisterCase

