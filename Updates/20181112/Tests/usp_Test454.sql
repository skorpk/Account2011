USE RegisterCases
GO
if OBJECT_ID('usp_Test454',N'P') is not NULL
	DROP PROCEDURE usp_Test454
GO
CREATE PROC dbo.usp_Test454
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Обязательно присутствует, если ONK_USL/USL_TIP in (2,4). 
*/
INSERT #tError
SELECT DISTINCT c.id,454
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 IN(2,4) AND NOT EXISTS(SELECT * FROM t_DrugTherapy WHERE rf_idCase=c.id)
/*
Если присутствует, то LEK_PR/REGNUM Not is null and LEK_PR/CODE_SH not is null and LEK_PR/DATE_INJ not is null
Данная проверка отпадает т.к. вынесена на уровень схемы
*/
GO
GRANT EXECUTE ON usp_Test454 TO db_RegisterCase