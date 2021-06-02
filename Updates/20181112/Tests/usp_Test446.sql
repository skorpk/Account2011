USE [RegisterCases]
GO

if OBJECT_ID('usp_Test446',N'P') is not NULL
	DROP PROCEDURE usp_Test446
GO
create PROC dbo.usp_Test446
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,446
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.KD IS NULL AND c.rf_idV006<3 AND c.rf_idV010<>4


;WITH cteStac
AS(
	SELECT c.id, c.KD, CASE WHEN DateBegin<DateEnd THEN DATEDIFF(DAY,c.DateBegin, c.DateEnd) ELSE 1 END AS DayDiff
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'				 
	where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=1	AND c.KD IS NOT NULL AND c.rf_idV010<>4
)
insert #tError
SELECT DISTINCT c.id,446
FROM cteStac c
WHERE c.KD<>DayDiff

;WITH cteDnStac
AS(
	SELECT c.id, c.KD, DATEDIFF(DAY,c.DateBegin, c.DateEnd)+1 AS DayDiff
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'				 
	where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=2	AND c.KD IS NOT NULL
)
insert #tError
SELECT DISTINCT c.id,446
FROM cteDnStac c
WHERE c.KD>DayDiff

insert #tError
SELECT DISTINCT c.id,446
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=2	AND c.KD =0

GO
GRANT EXECUTE ON usp_Test446 TO db_RegisterCase

