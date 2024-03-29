USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test510]    Script Date: 08.02.2021 14:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test510]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--510
--Проводится проверка 1: если VIDPOM=32, то поле должно быть заполнено обязательно и указанное значение должно соответствовать классификатору методов ВМП V019 
--(поле IDHM) на дату окончания лечения(03.02.2016). Если значение соответствует классификатору методов ВМП, то проводится проверка соответствия указанного метода ВМП виду ВМП 
--(справочник соответствия видов ВМП и методов ВМП) и проводится проверка соответствия основного диагноза диагнозам, 
--при которых применяется указанный метод ВМП (справочник соответствия методов ВМП диагнозам).
insert #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008=32 AND c.rf_idV019 IS NULL
--Проводится проверка 2: если поле заполнено, то VIDPOM должен быть равен 32 и указанное значение должно соответствовать классификатору V019 (поле IDHМ).
insert #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008<>32 AND c.rf_idV019 IS NOT NULL
/*
Если значение соответствует классификатору методов ВМП, то на дату окончания лечения проводится проверка соответствия указанного метода ВМП виду ВМП(значение в поле VID_HMP) 
(справочник соответствия видов ВМП и методов ВМП oms_nsi.dbo.sprV019V018V022Relation). 
Для таблицы oms_nsi.dbo.sprV019V018V022Relation составной ключ IDHM+VIDHM не является уникальным, поэтому при проверке наличия соответствия вида и метода ВМП поиск может вернуть более одной записи.
*/
insert #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV019 IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprV019_2021 WHERE IDHM=c.rf_idV019 AND IDHVID=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd)
