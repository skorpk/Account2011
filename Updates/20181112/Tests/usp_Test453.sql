USE RegisterCases
GO
if OBJECT_ID('usp_Test453',N'P') is not NULL
	DROP PROCEDURE usp_Test453
GO
CREATE PROC dbo.usp_Test453
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Если ONK_USL/USL_TIP in (3,4), то WEI обязательно заполняется.
*/
INSERT #tError
SELECT DISTINCT c.id,453
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.PPTR IS NOT null AND (ou.PPTR<>1 OR ou.rf_idN013 NOT IN(2,4))
GO
GRANT EXECUTE ON usp_Test453 TO db_RegisterCase