USE RegisterCases
GO
if OBJECT_ID('usp_Test474',N'P') is not NULL
	DROP PROCEDURE usp_Test474
GO
CREATE PROC dbo.usp_Test474
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT DISTINCT c.id,474
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
			INNER JOIN dbo.t_ONK_SL o ON
		c.id=o.rf_idCase
			INNER JOIN dbo.t_DiagnosticBlock d ON
		o.id=d.rf_idONK_SL         
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND (d.DateDiagnostic<'20180901' OR d.DateDiagnostic>cc.DateEnd)
GO
GRANT EXECUTE ON usp_Test474 TO db_RegisterCase