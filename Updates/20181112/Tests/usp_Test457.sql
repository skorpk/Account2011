USE RegisterCases
GO
if OBJECT_ID('usp_Test457',N'P') is not NULL
	DROP PROCEDURE usp_Test457
GO
CREATE PROC dbo.usp_Test457
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,457
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
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DateInjection NOT BETWEEN c.DateBegin AND c.DateEnd

GO
GRANT EXECUTE ON usp_Test457 TO db_RegisterCase