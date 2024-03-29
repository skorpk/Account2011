USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test554]    Script Date: 31.01.2017 10:36:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test554]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
--CODE_MES1
--Проверка 4: проверка того что в таблице МЕС лежат только коды законченных случаев
--116.12.2013 добавилась проверка на справочник КСГ
insert #tError
select rf_idCase,554
from (
		select mes.rf_idCase,mes.MES as MUCode
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
							inner join t_Case c on
						r.id=c.rf_idRecordCase	
							inner join t_MES mes on
						c.id=mes.rf_idCase							
	  ) t 
where NOT EXISTS(SELECT * FROM vw_CompletedMUAndCSG WHERE MU=t.MUCode)

--Проверка 5: что в таблице медуслуг нету кодов законченых случаев
--16.12.2013 включил КСГ
insert #tError
select rf_idCase,554
from (
		select m.rf_idCase,m.MUCode
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
							inner join t_Case c on
					r.id=c.rf_idRecordCase
							inner join t_Meduslugi m on
					c.id=m.rf_idCase							
	  ) t inner join vw_CompletedMUAndCSG t1 on
			t.MUCode=t1.MU

			
--Если в теге USL при стационарной помощи присутствуют услуги отличные от A16 
--04.01.2014 при ЗС простовляются медуслуги в таблицу t_Meduslugi
insert #tError
select c.id,554
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN(VALUES(1),(2)) v(idV006) ON
				c.rf_idV006=v.idV006                      
						inner join t_MES mes on
				c.id=mes.rf_idCase		
							INNER JOIN t_Meduslugi m on									
				mes.rf_idCase=m.rf_idCase
				AND m.MUCode NOT IN (SELECT IDRB FROM OMS_NSI.dbo.V001)
WHERE NOT EXISTS(SELECT * FROM vw_CompletedMUAndCSG WHERE MU=mes.MES) 
--если код медицинской услуги  не соответствует кодам из Справочника медицинских услуг и их тарифов с учетом профиля, то выдаем ошибку 554
--2016-09-28 Убрать из фильтра условие c.IsSpecialCase NOT IN(3,4,23,24) и брать профиль на уровне медуслуг(всегда)
insert #tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
			AND c.IsCompletedCase=0	
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase	
						INNER JOIN dbo.vw_sprMU sm ON					
			m.MUCode=sm.MU
where m.Price>0 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMuProfilPaymentByAge WHERE Age=c.IsChild AND ProfileCode=m.rf_idV002 AND MUCode=m.MUCode AND PaymentMethodCode=c.rf_idV010)
--2016-08-10
--применение услуг из Классификатора стоматологических услуг(КСУ) разрешено применять только для амбулаторных случаев с определенными значениями в поле PROFIL на уровне случая
--08.11.2016 Выяснилось, что наши тетки прировняли стомат.хирургическую к челюстно лицевой
insert #tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE c.rf_idV006=3 AND c.rf_idV008>10 AND c.rf_idV008<14 AND c.rf_idV002 NOT IN(63,85,86,87,88,89,90,140,171) 		
--начиная с отчетного периода август 2016, на наличие в теге USL хотя бы одной услуги из Классификатора стоматологических услуг
insert #tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd						
WHERE  c.rf_idV006=3 AND c.rf_idV008>10 AND c.rf_idV008<14 AND c.DateEnd>='20160801' AND c.rf_idV002 IN(63,85,86,87,88,89,90,140,171) AND NOT EXISTS
   (SELECT * 
   FROM OMS_NSI.dbo.sprDentalMU dm inner join dbo.t_Meduslugi m on
			 m.MUCode=dm.code
   WHERE m.rf_idCase=c.id) 
----------------------------------------------------------------
insert #tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE c.rf_idV006=3 AND c.rf_idV008>10 AND c.rf_idV008<14 AND c.rf_idV002 IN(63,85,86,87,88,89,90,140,171) 
		AND  NOT EXISTS(SELECT * FROM dbo.vw_sprDentalMUProfilConditionPRVS WHERE MUCode=m.MUCode AND rf_idV006=c.rf_idV006 AND rf_idV002=m.rf_idV002 AND rf_idV015=m.rf_idV004)
--Для USL_OK=4 применение услуг из КСУ не приемлеммо.
insert #tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE c.rf_idV006=4
--Если USL_OK =1 или 2, то услуга из КСУ должна быть в справочнике номенклатур медицинских услуг
insert #tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						INNER JOIN (VALUES(1),(2)) v(idV006) ON
			c.rf_idV006=v.idV006                      
						inner join dbo.t_Meduslugi m on
			c.id=m.rf_idCase				
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
			m.MUCode=dm.code
WHERE NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUCode)
