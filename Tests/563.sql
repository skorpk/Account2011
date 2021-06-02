USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT=63256



select @idFile=id from vw_getIdFileNumber where CodeM='125505' and NumberRegister=6 AND ReportYear=2016
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончани€ отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

select c.id, 563
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile																					
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							LEFT JOIN dbo.vw_IsSpecialCase s ON
				c.IsSpecialCase=s.OS_SLUCH							
where c.IsSpecialCase is NOT NULL AND s.OS_SLUCH IS NULL
------2013-08-05
------2013-10-11
--проверка на корректность заполнени€ пол€ OS_SLUCH 
--- 1 вариант когда поле OS заполнено в справочнике

select c.id, 563
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile																					
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.IsCompletedCase=1
							INNER JOIN t_Mes m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mc ON
				m.MES=mc.MU
				AND (CASE WHEN LEN(c.IsSpecialCase)=2 THEN RIGHT(c.IsSpecialCase,1) ELSE ISNULL(c.IsSpecialCase,2) END)<>mc.IsSpecialCase
WHERE mc.IsSpecialCase IS NOT NULL 

--- 2 вариант когда поле OS пусто в справочнике

select DISTINCT mc.MU
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile																					
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.IsCompletedCase=1
							INNER JOIN t_Mes m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mc ON
				m.MES=mc.MU
WHERE mc.IsSpecialCase IS NULL AND ISNULL(c.IsSpecialCase,2)<>2

select c.id, 563,c.IsSpecialCase,mc.MU,mc.IsSpecialCase
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile																					
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.IsCompletedCase=1
							INNER JOIN t_Mes m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mc ON
				m.MES=mc.MU
WHERE mc.IsSpecialCase IS NULL AND ISNULL(c.IsSpecialCase,2)<>2
---2013-08-05
-- проверка медуслуг
--»зменени€ от 20.10.2014 Ќеобходимо провер€ть только медуслуги с ненулевым тарифом

select c.id, 563
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile																					
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							INNER JOIN t_Meduslugi m ON
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUNotCompletedCase mc ON
				m.MUCode=mc.MU
				AND (CASE WHEN LEN(c.IsSpecialCase)=2 THEN RIGHT(c.IsSpecialCase,1) ELSE ISNULL(c.IsSpecialCase,2) END)<>mc.IsSpecialCase
WHERE mc.IsSpecialCase IS NOT NULL AND m.Price>0