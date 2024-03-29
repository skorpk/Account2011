USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test504]    Script Date: 16.01.2020 11:00:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test504]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--Если в качестве IDSP=33
--проверка корректности представленной информации о фактическом количестве оказанных койко-дней для случая. 
--Проверка проводится сначала на уровне каждого составного тега USL, в котором представлены сведения только об услугах 1.11.1. 
--Если в составном теге USL  CODE_USL=1.11.1 , то значение в теге KOL_USL должно быть равно разности между датой окончания оказания услуги (DATE_OUT) 
--и датой начала оказания услуги (DATE_IN), или 1, если даты равны (DATE_IN=DATE_OUT).
insert #tError
select distinct c.id,504
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode='1.11.1'	
WHERE c.rf_idV010=33  AND c.rf_idV006=1 AND mu.Quantity<>mu.CSGQuantity
--проводится проверка корректности представления информации на уровне случая: общее количество всех медуслуг с кодом 1.11.1, 
--представленных в данном случае,  должно быть  равно разности между датой окончания лечения (DATE_2 в составном теге SLUCH) 
--и датой начала лечения (DATE_1 в составном теге SLUCH). Если DATE_1=DATE_2, то разность принимается равной 1. 
insert #tError
SELECT c.id,504
FROM (
		select c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END) AS QuantityCase,SUM(mu.CSGQuantity) AS CSGQuantity
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase									
								INNER JOIN dbo.t_Meduslugi mu ON
					c.id=mu.rf_idCase
					AND mu.MUCode='1.11.1'	
		WHERE c.rf_idV010=33 AND c.rf_idV006=1
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END)
	) c
WHERE c.QuantityCase<>c.CSGQuantity
----23.01.2015 добавился новый способ оплаты
/*
проводится проверка корректности представленной информации о фактическом количестве оказанных пациенто-дней для случая. 
Проверка проводится сначала на уровне каждого составного тега USL, в котором представлены сведения только об услугах из класса 55.1.* 
Если в составном теге USL  CODE_USL из класса 55.1.* , 
то значение в теге KOL_USL должно быть не больше разности между датой окончания оказания услуги (DATE_OUT) 
и датой начала оказания услуги (DATE_IN) плюс 1, или 1, если даты равны (DATE_IN=DATE_OUT). 
После проведения проверки на уровне составных тегов USL, в которых представлены сведения о медуслугах из класса 55.1.*, 
проводится проверка корректности представления информации на уровне случая: общее количество всех медуслуг из класса 55.1.*, 
представленных в данном случае,  должно быть  не больше разности между датой окончания лечения (DATE_2 в составном теге SLUCH) 
и датой начала лечения (DATE_1 в составном теге SLUCH) плюс 1. Если DATE_1=DATE_2, то разность принимается равной 1
*/
insert #tError
select distinct c.id,504
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode LIKE '55.1.%'
WHERE c.rf_idV010 IN(43,33) AND c.rf_idV006=2  AND mu.Quantity>mu.PacientQuantity

insert #tError
SELECT c.id,504
FROM (
		select c.id
				,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd)+1 END ) AS QuantityCase
				,SUM(mu.PacientQuantity) AS MUQuantity
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase									
								INNER JOIN dbo.t_Meduslugi mu ON
					c.id=mu.rf_idCase
					AND mu.MUCode LIKE '55.1.%'
		WHERE c.rf_idV010 IN(43,33) AND c.rf_idV006=2
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd)+1 END ) 
	) c
WHERE c.QuantityCase<c.MUQuantity
/*
Если в качестве IDSP=32
проводится проверка корректности представленной информации о фактическом количестве оказанных койко-дней для случая. 
Проверка проводится сначала на уровне каждого составного тега USL, в котором представлены сведения только об услугах 1.11.*. 
Если в составном теге USL  CODE_USL=1.11.* , то значение в теге KOL_USL должно быть равно разности между датой окончания оказания услуги (DATE_OUT) и 
датой начала оказания услуги (DATE_IN), или 1, если даты равны (DATE_IN=DATE_OUT). После проведения проверки на уровне составных тегов USL, 
в которых представлены сведения о медуслугах с кодом 1.11.*, проводится проверка корректности представления информации на уровне случая: 
общее количество всех медуслуг с кодом 1.11.*, представленных в данном случае,  должно быть  равно разности между датой окончания 
лечения (DATE_2 в составном теге SLUCH) и датой начала лечения (DATE_1 в составном теге SLUCH). Если DATE_1=DATE_2, то разность принимается равной 1. 
*/
insert #tError
select distinct c.id,504
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode LIKE '1.11.%'	
WHERE c.rf_idV010=32  AND mu.Quantity<>mu.CSGQuantity
--проводится проверка корректности представления информации на уровне случая: общее количество всех медуслуг с кодом 1.11.1, 
--представленных в данном случае,  должно быть  равно разности между датой окончания лечения (DATE_2 в составном теге SLUCH) 
--и датой начала лечения (DATE_1 в составном теге SLUCH). Если DATE_1=DATE_2, то разность принимается равной 1. 
insert #tError
SELECT c.id,504
FROM (
		select c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END) AS QuantityCase,SUM(mu.CSGQuantity) AS CSGQuantity
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 
								inner join t_PatientSMO s on
					r.id=s.ref_idRecordCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd								
								INNER JOIN dbo.t_Meduslugi mu ON
					c.id=mu.rf_idCase
					AND mu.MUCode LIKE '1.11.%'	
		WHERE c.rf_idV010=32
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd) END)
	) c
WHERE c.QuantityCase<>c.CSGQuantity
