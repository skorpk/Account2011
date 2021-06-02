USE RegisterCases
GO
if OBJECT_ID('usp_Test470',N'P') is not NULL
	DROP PROCEDURE usp_Test470
GO
CREATE PROC dbo.usp_Test470
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError 
SELECT c.id,470
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
				INNER JOIN dbo.t_DS_ONK_REAB d ON
		c.id=d.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND p.NAZR IN (2,3) AND d.DS_ONK=1 AND (p.DirectionDate NOT BETWEEN cc.DateBegin AND cc.DateEnd)

GO

GRANT EXECUTE ON usp_Test470 TO db_RegisterCase