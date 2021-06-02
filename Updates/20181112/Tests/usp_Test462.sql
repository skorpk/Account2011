USE RegisterCases
GO
if OBJECT_ID('usp_Test462',N'P') is not NULL
	DROP PROCEDURE usp_Test462
GO
CREATE PROC dbo.usp_Test462
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH cte
AS (
	SELECT r.id AS IdPatient,cc.AmountPayment,SUM(c.AmountPayment) AS SUM_M
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
	where a.rf_idFiles=@idFile 
	GROUP BY r.id,cc.AmountPayment
)
INSERT #tError SELECT cc.id,462
FROM cte c INNER JOIN dbo.t_Case cc ON
		c.IdPatient=cc.rf_idRecordCase
WHERE c.AmountPayment<>c.SUM_M
GO

GRANT EXECUTE ON usp_Test462 TO db_RegisterCase