USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='104401' and NumberRegister=46543 and ReportYear=2021

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
--510
--Проводится проверка 1: если VIDPOM=32, то поле должно быть заполнено обязательно и указанное значение должно соответствовать классификатору методов ВМП V019 
--(поле IDHM) на дату окончания лечения(03.02.2016). Если значение соответствует классификатору методов ВМП, то проводится проверка соответствия указанного метода ВМП виду ВМП 
--(справочник соответствия видов ВМП и методов ВМП) и проводится проверка соответствия основного диагноза диагнозам, 
--при которых применяется указанный метод ВМП (справочник соответствия методов ВМП диагнозам).
 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008=32 AND c.rf_idV019 IS NULL

--Проводится проверка 2: если поле заполнено, то VIDPOM должен быть равен 32 и указанное значение должно соответствовать классификатору V019 (поле IDHМ).
 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008<>32 AND c.rf_idV019 IS NOT NULL
--на дату окончания лечения(03.02.2016)
 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV019 IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprV019_2021 WHERE IDHM=c.rf_idV019 AND IDHVID=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd)

