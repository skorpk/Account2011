USE RegisterCases
GO
if(OBJECT_ID('usp_Test313',N'P')) is not null
	drop PROCEDURE dbo.usp_Test313
go
CREATE PROC dbo.usp_Test313
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS


INSERT #tError
SELECT DISTINCT c.id,'313'
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
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND p.rf_idV025 ='1.3' AND ISNULL(c.C_ZAB,9) NOT IN(2,3)


GO
GRANT EXECUTE ON usp_Test313 TO db_RegisterCase