USE RegisterCases
GO
if OBJECT_ID('usp_Test459',N'P') is not NULL
	DROP PROCEDURE usp_Test459
GO
CREATE PROC dbo.usp_Test459
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

--INSERT #tError
--SELECT DISTINCT c.id,459
SELECT r.id
INTO #tPatient
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'						
where a.rf_idFiles=@idFile AND f.TypeFile='H' 
GROUP BY r.id
HAVING COUNT(*)=2

;WITH cte
AS(
SELECT r.id,c.DateBegin,c.DateEnd, ROW_NUMBER() OVER(PARTITION BY r.id ORDER BY c.DateBegin,c.DateEnd) AS idRow
from  #tPatient r inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'						
--where a.rf_idFiles=@idFile AND f.TypeFile='H' 
)
INSERT #tError
SELECT DISTINCT c.id,459
FROM cte c1 INNER JOIN cte c2 ON
		c1.id= c2.id
		AND c1.idRow>c2.idRow
		AND c1.DateBegin<>c2.DateEnd
			INNER JOIN dbo.t_Case c ON
		c1.id=c.rf_idRecordCase          



GO
GRANT EXECUTE ON usp_Test459 TO db_RegisterCase