USE RegisterCases
GO
if OBJECT_ID('usp_Test464',N'P') is not NULL
	DROP PROCEDURE usp_Test464
GO
CREATE PROC dbo.usp_Test464
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS (
	SELECT r.id AS IdPatient,c.id, d.DS1, ROW_NUMBER() OVER(PARTITION BY r.id ORDER BY c.id) AS idRow
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'				
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase              
	where a.rf_idFiles=@idFile AND f.TypeFile='H'
)
INSERT #tError SELECT c.id,464
FROM cte c INNER JOIN cte c1 ON
		c.IdPatient = c1.IdPatient
WHERE c.DS1<>c1.DS1
GO

GRANT EXECUTE ON usp_Test464 TO db_RegisterCase