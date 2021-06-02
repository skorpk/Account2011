USE RegisterCases
GO
if(OBJECT_ID('usp_Test318',N'P')) is not null
	drop PROCEDURE dbo.usp_Test318
go
CREATE PROC dbo.usp_Test318
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--«начени€ в тегах CRIT не должны совпадать

;WITH cte
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY m.rf_idAddCretiria) AS idRow,c.id,m.rf_idAddCretiria
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				  INNER JOIN dbo.t_AdditionalCriterion m ON
	        c.id=m.rf_idCase
	where a.rf_idFiles=@idFile 
)
INSERT #tError
SELECT DISTINCT c1.id,'318'
FROM cte c1 INNER JOIN cte c2 ON
		c1.id=c2.id
		AND c1.rf_idAddCretiria=c2.rf_idAddCretiria
WHERE c1.idRow<>c2.idRow
/*
≈сли в тегах CRIT присутствует более одного значени€, то допускаетс€ сочетание следующих значений:  {like 'mt%' и like Сfr%Т} или{ like 'sh%' и like Сsh%Т }. 
ѕервое сочетание определ€ет проведение химиолучевой терапии, второе сочетание определ€ет применение в случае двух разных схем химиотерапии. 
*/

;WITH cte
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY m.rf_idAddCretiria) AS idRow,c.id,m.rf_idAddCretiria
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				  INNER JOIN dbo.t_AdditionalCriterion m ON
	        c.id=m.rf_idCase
	where a.rf_idFiles=@idFile 
)
INSERT #tError
SELECT c1.id,518
FROM cte c1 INNER JOIN cte c2 ON
		c2.id = c1.id
		AND c1.idRow <> c2.idRow
WHERE (c1.rf_idAddCretiria LIKE 'mt%' OR c1.rf_idAddCretiria LIKE 'fr%') AND (c2.rf_idAddCretiria NOT LIKE 'fr%' and c2.rf_idAddCretiria NOT LIKE 'mt%')

;WITH cte
AS(
	SELECT ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY m.rf_idAddCretiria) AS idRow,c.id,m.rf_idAddCretiria
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				  INNER JOIN dbo.t_AdditionalCriterion m ON
	        c.id=m.rf_idCase
	where a.rf_idFiles=@idFile 
)
INSERT #tError
SELECT c1.id,518
FROM cte c1 INNER JOIN cte c2 ON
		c2.id = c1.id
		AND c1.idRow <> c2.idRow
WHERE c1.rf_idAddCretiria LIKE 'sh%'  AND c2.rf_idAddCretiria NOT LIKE 'sh%'
GO
GRANT EXECUTE ON usp_Test318 TO db_RegisterCase