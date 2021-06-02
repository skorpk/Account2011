USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test307',N'P')) is not null
	drop PROCEDURE dbo.usp_Test307
go
CREATE PROC dbo.usp_Test307
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS(
SELECT c.id,d.rf_idN013,MIN(d.rf_idV020) AS MinVal,MAX(d.rf_idV020) AS MaxVal,d.rf_idV020
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
GROUP BY c.id,d.rf_idN013,d.rf_idV020
)
insert #tError SELECT DISTINCT id,307 FROM cte WHERE cte.MinVal=cte.MaxVal AND rf_idV020 IN('000895','000903','001652','000764')
GO
GRANT EXECUTE ON usp_Test307 TO db_RegisterCase