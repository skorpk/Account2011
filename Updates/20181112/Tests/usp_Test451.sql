USE RegisterCases
GO
if OBJECT_ID('usp_Test451',N'P') is not NULL
	DROP PROCEDURE usp_Test451
GO
CREATE PROC dbo.usp_Test451
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Если ONK_USL/USL_TIP in (3,4), то K_FR обязательно для заполнения, причем K_FR>=0.
*/
INSERT #tError
SELECT DISTINCT c.id,451
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 IN(3,4)	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND ISNULL(K_FR,0)>0)

/*
Если в одном из значений CRIT представлено значение like 'fr%', то K_FR  обязательно для заполнения, причем K_FR>=0.
*/
INSERT #tError
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'fr%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND ISNULL(K_FR,0)>0)

INSERT #tError
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
			 INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'fr%' AND NOT EXISTS(SELECT 1 FROM vw_sprV024_Fraction WHERE IDDKK=ad.rf_idAddCretiria AND sl.K_FR >=MinValue AND sl.K_FR<=MaxValue )
GO
GRANT EXECUTE ON usp_Test451 TO db_RegisterCase