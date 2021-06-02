USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test302',N'P')) is not null
	drop PROCEDURE dbo.usp_Test302
go
CREATE PROC dbo.usp_Test302
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,302
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS1 LIKE 'P07%' AND r.IsChild=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_BirthWeight b WHERE c.id=b.rf_idCase)

GO
GRANT EXECUTE ON usp_Test302 TO db_RegisterCase