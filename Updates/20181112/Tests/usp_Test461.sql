USE RegisterCases
GO
if OBJECT_ID('usp_Test461',N'P') is not NULL
	DROP PROCEDURE usp_Test461
GO
CREATE PROC dbo.usp_Test461
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS (
	SELECT r.id AS IdPatient,c.id, ROW_NUMBER() OVER(PARTITION BY r.id ORDER BY c.id) AS idRow
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'									
	where a.rf_idFiles=@idFile AND f.TypeFile='F'
)
INSERT #tError SELECT c.id,461
FROM cte c 
WHERE c.idRow>1
GO

GRANT EXECUTE ON usp_Test461 TO db_RegisterCase