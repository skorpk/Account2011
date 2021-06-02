USE [RegisterCases]
GO
ALTER PROC [dbo].[usp_Test567]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

SELECT ROW_NUMBER() OVER(PARTITION BY a.rf_idFiles ORDER BY C.id) AS num
INTO #tNum
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
where a.rf_idFiles=@idFile 

insert #tError
SELECT DISTINCT c.id,567
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase					
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM #tNum WHERE m.id=num )

DROP TABLE #tNum
GO
GRANT EXECUTE ON usp_Test567 TO db_RegisterCase
go

