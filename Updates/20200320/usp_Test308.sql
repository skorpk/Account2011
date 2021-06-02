USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test308',N'P')) is not null
	drop PROCEDURE dbo.usp_Test308
go
CREATE PROC dbo.usp_Test308
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS(
SELECT c.id,d.rf_idN013,d.rf_idV020,d.DateInjection
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_DrugTherapy d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' 
GROUP BY c.id,d.rf_idN013,d.rf_idV020,d.DateInjection
HAVING COUNT(*)>1
)
insert #tError SELECT DISTINCT id,308 FROM cte 
GO
GRANT EXECUTE ON usp_Test308 TO db_RegisterCase