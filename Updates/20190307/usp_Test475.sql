USE RegisterCases
GO
if OBJECT_ID('usp_Test475',N'P') is not NULL
	DROP PROCEDURE usp_Test475
GO
CREATE PROC dbo.usp_Test475
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS(
	SELECT cc.id AS rf_idCompletedCase, c.id, c.rf_idV002
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'				
				INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase 			       
	where a.rf_idFiles=@idFile AND f.TypeFile='H' 
	
	)	
INSERT #tError
SELECT c1.id,475
FROM cte c1 INNER JOIN cte c2 ON
		c1.rf_idCompletedCase = c2.rf_idCompletedCase
		AND c1.id <> c2.id
WHERE c1.rf_idV002<>c2.rf_idV002
GO
GRANT EXECUTE ON usp_Test475 TO db_RegisterCase