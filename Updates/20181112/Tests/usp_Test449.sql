USE [RegisterCases]
GO
if OBJECT_ID('usp_Test449',N'P') is not NULL
	DROP PROCEDURE usp_Test449
GO
CREATE PROC dbo.usp_Test449
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT DISTINCT c.id,449
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 IN(1,3,4,6) 
		AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUSurgery IS NOT null)
GO
GRANT EXECUTE ON usp_Test449 TO db_RegisterCase