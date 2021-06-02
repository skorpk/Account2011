USE RegisterCases
GO
if OBJECT_ID('usp_Test450',N'P') is not NULL
	DROP PROCEDURE usp_Test450
GO
CREATE PROC dbo.usp_Test450
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT DISTINCT c.id,450
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006 <3 AND c.rf_idV008 IN(3,31,13,12) AND c.rf_idV010 IN (33,43)
	AND NOT EXISTS(SELECT 1 FROM dbo.t_MES WHERE rf_idCase=c.id AND IsCSGTag=2)
GO
GRANT EXECUTE ON usp_Test450 TO db_RegisterCase