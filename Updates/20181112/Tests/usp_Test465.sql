USE RegisterCases
GO
if OBJECT_ID('usp_Test465',N'P') is not NULL
	DROP PROCEDURE usp_Test465
GO
CREATE PROC dbo.usp_Test465
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError 
SELECT c.id,465
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'				
				INNER JOIN dbo.vw_CoefficientAvr cf ON
		c.id=cf.rf_idCase								
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.IT_SL<>cf.AvrValc AND cf.CountIT_SL>1

GO

GRANT EXECUTE ON usp_Test465 TO db_RegisterCase