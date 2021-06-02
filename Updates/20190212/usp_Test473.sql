USE RegisterCases
GO
if OBJECT_ID('usp_Test473',N'P') is not NULL
	DROP PROCEDURE usp_Test473
GO
CREATE PROC dbo.usp_Test473
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError 
SELECT c.id,473
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
				INNER JOIN dbo.t_Prescriptions p ON
		c.id=p.rf_idCase		
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND p.NAZR=6 AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV020 WHERE code=ISNULL(p.rf_idV020,0) AND cc.DateEnd BETWEEN DateBeg AND DateEnd)

GO

GRANT EXECUTE ON usp_Test473 TO db_RegisterCase