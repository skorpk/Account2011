USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test303',N'P')) is not null
	drop PROCEDURE dbo.usp_Test303
go
CREATE PROC dbo.usp_Test303
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,303
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'						
			INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase	 			
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.Age>0 AND d.DS1 LIKE 'P%'

GO
GRANT EXECUTE ON usp_Test303 TO db_RegisterCase