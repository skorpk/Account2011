USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=66 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile
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

select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008=32 AND c.rf_idV018 IS NULL

SELECT c.id,509,c.rf_idV018
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase					
WHERE c.rf_idV008=32 AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.sprV018 WHERE code=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd) 		

SELECT * FROM OMS_NSI.dbo.sprV018 WHERE code='09.00.15.002'

select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008<>32 AND c.rf_idV018 IS NOT NULL				
--на дату окончания лечения(03.02.2016)
select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase					
WHERE c.rf_idV018 IS NOT NULL AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.sprV018 WHERE code=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd) 
