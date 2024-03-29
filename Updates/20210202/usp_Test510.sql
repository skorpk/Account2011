USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test510]    Script Date: 02.02.2021 15:34:15 ******/
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
/*
INSERT #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase					
						INNER JOIN (SELECT DISTINCT rf_idCase,RTRIM(DiagnosisCode) AS DiagnosisCode FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d ON
			c.id=d.rf_idCase
WHERE c.rf_idV008=32 AND NOT EXISTS(SELECT * FROM dbo.vw_sprV019 
									WHERE IDHM=c.rf_idV019 AND IDHVID=c.rf_idV018 AND RTRIM(DiagnosisCode)=RTRIM(d.DiagnosisCode) AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd ) 
*/
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
--на дату окончания лечения(03.02.2016)
insert #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV019 IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprV019_2021 WHERE IDHM=c.rf_idV019 AND DateBeg19<=c.DateEnd AND c.DateEnd<=DateEnd19 AND DateBeg18<=c.DateEnd AND c.DateEnd<=DateEnd18)
/*
если VIDPOM=32 и  (IDSP=32 или IDSP=34), то в качестве CODE_MES1 используется код законченного случая (не код КСГ). 
При этом значение, указанное в коде после второй точки (для кода ХХ.ХХ.YYY – это значение YYY), должно быть равно значению в поле METOD_HMP.
*/
INSERT #tError
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
WHERE c.rf_idV008=32  AND c.rf_idV010=32 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMUCompletedCase WHERE MU=m.MES)
INSERT #tError
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
WHERE c.rf_idV008=32  AND c.rf_idV010=34 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMUCompletedCase WHERE MU=m.MES)

INSERT #tError
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase					
WHERE c.rf_idV008=32  AND c.rf_idV010=32 AND  m.V018<>CAST(c.rf_idV019 AS VARCHAR(20))
-- V018 вычисляемя колонка в таблице t_MES
INSERT #tError
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase					
WHERE c.rf_idV008=32  AND c.rf_idV010=34 AND  m.V018<>CAST(c.rf_idV019 AS VARCHAR(20))
