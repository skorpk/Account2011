USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber WHERE CodeM='611001' AND ReportYear=2019 AND NumberRegister=251

select * from vw_getIdFileNumber where id=@idFile

DECLARE @startnum INT=1
DECLARE @endnum INT

SELECT ROW_NUMBER() OVER(PARTITION BY a.rf_idFiles ORDER BY C.id) AS num
INTO #tNum
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
where a.rf_idFiles=@idFile 

SELECT DISTINCT c.id,567
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase					
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM #tNum WHERE m.id=num )
GO
DROP TABLE #tNum