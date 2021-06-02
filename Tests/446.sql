USE RegisterCases
GO
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='141023' and NumberRegister=19 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile


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

SELECT DISTINCT c.id,446
FROM cteStac c
WHERE c.KD<>DayDiff


;WITH cteStac
AS(
	SELECT c.id, c.KD, SUM(m.Quantity) AS DayDiff
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'	
				  INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase			 
	where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=1	AND c.KD IS NOT NULL AND c.rf_idV010<>4 AND m.MUCode LIKE '1.11.%'
	GROUP BY c.id, c.KD
)

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

SELECT DISTINCT c.id,446
FROM cteDnStac c
WHERE c.KD>DayDiff

;WITH cteDnStac
AS(
	SELECT c.id, c.KD, SUM(m.Quantity) AS DayDiff
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'	
				  INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase			 
	where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=2	/*AND c.KD IS NOT NULL*/ AND c.rf_idV010<>4 AND m.MUCode LIKE '55.1.%'
	GROUP BY c.id, c.KD
)

SELECT DISTINCT c.id,446
FROM cteDnStac c
WHERE c.KD<>DayDiff


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

