USE RegisterCases
GO
if(OBJECT_ID('usp_Test_USL_OK_FOR_POM',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_USL_OK_FOR_POM
go
CREATE PROC dbo.usp_Test_USL_OK_FOR_POM
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
CREATE TABLE #t(errorCode varchar(15),rf_idV014 INT,USL_OK tinyint)
INSERT #t( errorCode, USL_OK,rf_idV014) VALUES('006F.00.1300',4,2),('006F.00.1300',4,1)
			,('006F.00.1280',2,2),('006F.00.1280',2,3)
			,('006F.00.1290',3,2),('006F.00.1290',3,3)
		

INSERT #tError
SELECT DISTINCT c.id,tt.errorCode
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'	
				JOIN #t tt ON
       c.rf_idV006=tt.USL_OK    
where a.rf_idFiles=@idFile AND f.TypeFile='H'
AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.USL_OK=c.rf_idV006 AND t.rf_idV014=c.rf_idV014)

GO
GRANT EXECUTE ON usp_Test_USL_OK_FOR_POM TO db_RegisterCase