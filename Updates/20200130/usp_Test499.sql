USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test499',N'P')) is not null
	drop PROCEDURE dbo.usp_Test499
go
CREATE PROC dbo.usp_Test499
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,499
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'							 
			INNER JOIN dbo.t_DispInfo d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND d.IsOnko=1 AND c.rf_idV009 IN(317,321,332,343,347)

GO
GRANT EXECUTE ON usp_Test499 TO db_RegisterCase