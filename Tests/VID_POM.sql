USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT--=127080

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='151005' AND ReportYear=2021 AND NumberRegister=58671

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile									  


--select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

CREATE TABLE #t(errorCode varchar(15),rf_idV008 smallINT,USL_OK tinyint)
INSERT #t( USL_OK,rf_idV008 ) VALUES(1,3),(1,21),(1, 31),(1, 32),(1, 33)
		,(2,12), (2,13), (2,14), (2,31), (2,32), (2,33)
		,(3,1), (3,2), (3,11), (3,12), (3,13), (3,4), (3,14)
		,(4,2),(4,21), (4,22), (4,23)
UPDATE #t SET errorCode='006F.00.1230' WHERE USL_OK=1
UPDATE #t SET errorCode='006F.00.1220' WHERE USL_OK=2
UPDATE #t SET errorCode='006F.00.1210' WHERE USL_OK=3
UPDATE #t SET errorCode='006F.00.1200' WHERE USL_OK=4

SELECT DISTINCT c.id,tt.errorCode,c.rf_idV006,c.rf_idV008
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
AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.USL_OK=c.rf_idV006 AND t.rf_idV008=c.rf_idV008)


GO
DROP TABLE #t