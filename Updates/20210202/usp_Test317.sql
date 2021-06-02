USE RegisterCases
GO
if(OBJECT_ID('usp_Test317',N'P')) is not null
	drop PROCEDURE dbo.usp_Test317
go
CREATE PROC dbo.usp_Test317
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

SELECT MU INTO #sMU FROM vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=8

INSERT #sMU
SELECT MU FROM vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode IN(76,79,80,81,82,83,84,85,86,87,88)

INSERT #tError
SELECT DISTINCT c.id,'317'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
			  INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
			 INNER JOIN #sMU s ON
        m.MUCode=s.MU
where a.rf_idFiles=@idFile AND m.Quantity<>1
GO
GRANT EXECUTE ON usp_Test317 TO db_RegisterCase