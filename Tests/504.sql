USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='151005' AND ReportYear=2018 AND NumberRegister=5
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))


select distinct c.id,504,mu.Quantity,mu.CSGQuantity, DateHelpBegin, DateHelpEnd
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
WHERE c.rf_idV010=33  AND mu.Quantity<>mu.CSGQuantity
--проводится проверка корректности представления информации на уровне случая: общее количество всех медуслуг с кодом 1.11.1, 
--представленных в данном случае,  должно быть  равно разности между датой окончания лечения (DATE_2 в составном теге SLUCH) 
--и датой начала лечения (DATE_1 в составном теге SLUCH). Если DATE_1=DATE_2, то разность принимается равной 1. 
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
		WHERE c.rf_idV010=33
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
WHERE c.rf_idV010=43  AND mu.Quantity>mu.PacientQuantity

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
		WHERE c.rf_idV010=43
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