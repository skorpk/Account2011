USE RegisterCases
GO
if(OBJECT_ID('usp_Test320',N'P')) is not null
	drop PROCEDURE dbo.usp_Test320
go
CREATE PROC dbo.usp_Test320
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,320
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'				  
			JOIN dbo.t_NextVisitDate nd ON
        c.id=nd.rf_idCase
where a.rf_idFiles=@idFile AND (c.rf_idV006<>3 OR NOT EXISTS(SELECT 1 FROM dbo.t_PurposeOfVisit p WHERE p.rf_idCase=c.id AND ISNULL(p.DN,9) IN(4,6,9) ))
AND c.rf_idV006<>3

GO
GRANT EXECUTE ON usp_Test320 TO db_RegisterCase