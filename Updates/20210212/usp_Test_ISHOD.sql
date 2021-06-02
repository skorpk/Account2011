USE RegisterCases
GO
if(OBJECT_ID('usp_Test_ISHOD',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_ISHOD
go
CREATE PROC dbo.usp_Test_ISHOD
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

CREATE TABLE #t(rf_idV009 SMALLINT, rf_idV0012 SMALLINT,CodeError VARCHAR(15), typeQ tinyint)
INSERT #t(rf_idV009,rf_idV0012,CodeError,typeQ) VALUES(405,403,'006F.00.1270',1),(406,403,'006F.00.1270',1),(313,305,'006F.00.1260',1)
		,(205,204,'006F.00.1250',1),(206,204,'006F.00.1250',1),(105,104,'006F.00.1140',1),(106,104,'006F.00.1140',1)

INSERT #t(rf_idV009,rf_idV0012,CodeError,typeQ) SELECT v.v009,201,'006F.00.1140',2 FROM (VALUES(202),(203),(204),(205),(206),(207),(208)) v(v009)
INSERT #t(rf_idV009,rf_idV0012,CodeError,typeQ) SELECT v.v009,101,'006F.00.1130',2 FROM (VALUES(102),(103),(104),(105),(106),(107),(108),(110)) v(v009)
INSERT #t(rf_idV009,rf_idV0012,CodeError,typeQ) SELECT v.v009,402,'006F.00.1120',1 FROM (VALUES(407),(408),(409),(410),(411),(412),(413),(414)) v(v009)

INSERT #tError
SELECT DISTINCT c.id,t.CodeError
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20210101'					
				INNER JOIN #t t ON
        c.rf_idV009=t.rf_idV009
where a.rf_idFiles=@idFile  AND t.typeQ=1 AND NOT EXISTS(SELECT 1 FROM #t tt WHERE c.rf_idV009=tt.rf_idV009 AND c.rf_idV012=tt.rf_idV0012 AND tt.typeQ=1)

INSERT #tError
SELECT DISTINCT c.id,t.CodeError
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20210101'					
				INNER JOIN #t t ON
        c.rf_idV009=t.rf_idV009
where a.rf_idFiles=@idFile  AND t.typeQ=2 AND EXISTS(SELECT 1 FROM #t tt WHERE c.rf_idV009=tt.rf_idV009 AND c.rf_idV012=tt.rf_idV0012 AND tt.typeQ=2)

DROP TABLE #t
GO
GRANT EXECUTE ON usp_Test_ISHOD TO db_RegisterCase