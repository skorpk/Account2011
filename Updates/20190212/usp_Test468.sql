USE RegisterCases
GO
if OBJECT_ID('usp_Test468',N'P') is not NULL
	DROP PROCEDURE usp_Test468
GO
CREATE PROC dbo.usp_Test468
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError 
SELECT c.id,468
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'				
				INNER JOIN dbo.t_Prescriptions p ON
		c.id=p.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND p.NAZR=3 AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprV029 WHERE IDMET=ISNULL(p.TypeExamination,0)) 

GO

GRANT EXECUTE ON usp_Test468 TO db_RegisterCase