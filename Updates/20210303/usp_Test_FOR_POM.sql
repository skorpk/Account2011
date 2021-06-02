USE RegisterCases
GO
if(OBJECT_ID('usp_Test_ISHOD',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_ISHOD
go
CREATE PROC dbo.usp_Test_FOR_POM
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,'003F.00.0820'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20210101'					
where a.rf_idFiles=@idFile  AND f.TypeFile='H' AND c.rf_idV002=158 AND c.rf_idV014<>3
GO
GRANT EXECUTE ON usp_Test_FOR_POM TO db_RegisterCase