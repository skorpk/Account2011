USE RegisterCases
GO
if OBJECT_ID('usp_Test452',N'P') is not NULL
	DROP PROCEDURE usp_Test452
GO
CREATE PROC dbo.usp_Test452
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Если ONK_USL/USL_TIP in (3,4), то WEI обязательно заполняется.
*/
INSERT #tError
SELECT DISTINCT c.id,452
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase            
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 =4	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND WEI IS NOT NULL)
GO
GRANT EXECUTE ON usp_Test452 TO db_RegisterCase