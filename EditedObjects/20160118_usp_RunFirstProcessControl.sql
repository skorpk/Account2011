USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_RunFirstProcessControl]    Script Date: 18.01.2016 11:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--не запускать пока не пройдена стадия тестирования	
ALTER proc [dbo].[usp_RunFirstProcessControl]
			@idFile int			
as
set nocount on

create table #tError (rf_idCase bigint,ErrorNumber smallint)

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
-----------------------------------------------------------------------Cases----------------------------------------------------
--дубликаты по IDSERV
insert #tError
select distinct c1.id,71
from(
		select c.id,m.id as IDSERV
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
				   				inner join t_Meduslugi m on
					c.id=m.rf_idCase
		where a.rf_idFiles=@idFile
	) c1 inner join (
						select m.id
						from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
											inner join t_Case c on																																					
								r.id=c.rf_idRecordCase
											inner join t_Meduslugi m on
								c.id=m.rf_idCase			
											left join t_MES mes on
								m.rf_idCase=mes.rf_idCase
						where a.rf_idFiles=@idFile and mes.rf_idCase is null
						group by m.id
						having COUNT(*)>1
					) c2 on c1.IDSERV=c2.id

--------------------------------Новые проверки от 10.12.2013------------------
declare @dateStartReceipt date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'11'
insert #tError
select distinct c.id,598
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile AND f.DateRegistration<@dateStartReceipt
------------------------------------------------------------------------------

--PR_NOV
insert #tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile and r.IsNew>1

insert #tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Case c1 on
			c.GUID_Case=c1.GUID_Case
			and c.id<>c1.id	
where a.rf_idFiles=@idFile and r.IsNew=0

insert #tError
select distinct c.id,531
from (
		select c.id,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
		where a.rf_idFiles=@idFile and r.IsNew=1
	 ) c left join t_Case c1 on
			c.GUID_Case=c1.GUID_Case
			and c.id<>c1.id	
where c1.id is null
--ID_PAC
--случаи в файле H без связи с файлом людей L
insert #tError
select distinct c.id,532
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					inner join t_Case c on
			r.id=c.rf_idRecordCase
					left join (select * from t_RegisterPatient where rf_idFiles=@idFile) p on
			r.ID_Patient=p.ID_Patient
where p.id is null
--VPOLIS
insert #tError
select distinct c.id,533
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprF08 f on
			r.rf_idF008=f.ID
where f.ID is null
--NPOLIS
--Проверка 10: поиск не корректных номеров полисов
insert #tError
select c.id,534
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.rf_idF008=2 and r.NPolisLen!=9

insert #tError 
select c.id,534
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.rf_idF008=3 and r.NPolisLen!=16
--SMO
insert #tError
select distinct c.id,535
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase			
			and s.OKATO<>'18000'
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprF002 f on
			s.rf_idSMO=f.SMOKOD
			and s.OKATO=f.TF_OKATO
where (s.rf_idSMO is not null) and f.SMOKOD is null

insert #tError
select distinct c.id,535
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
			and s.OKATO='18000'
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
where s.rf_idSMO is null
--SMO_OK
insert #tError
select distinct c.id,536
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprOKATO f on
			s.OKATO=f.OKATO
where f.OKATO is NULL AND NOT EXISTS(SELECT * FROM (VALUES('35000') ) v(OKATO) WHERE v.OKATO=s.OKATO)
--SMO_NAM
insert #tError
select distinct c.id,537
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
			and s.rf_idSMO is null
			and s.OKATO<>'18000'
						inner join t_Case c on
			r.id=c.rf_idRecordCase
where s.Name is null	
--NOVOR
--Проверка 11:если новорожденный то поле NOVOR заполняется по шаблону ПДДММГГН
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn)<>9

--если не новорожденный то кроме
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=0 and r.NewBorn<>'0'		
---проверка пола
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

--Проверка 12: если NOVOR=0 то недолжно быть записей в t_RegisterPatientAttendant
insert #tError 
select t.rf_idCase,538
from (
	  select c.id as rf_idCase, p.id as ID_Patient
	  from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join vw_RegisterPatient p on
				r.id=p.rf_idRecordCase
				and p.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase								
	  where r.IsChild=0 
	  ) t inner join t_RegisterPatientAttendant pa on
		t.ID_Patient=pa.rf_idRegisterPatient
--возраст пациента на дату начала лечения должен быть не меньше 0 и не больше 3 (возраст рассчитывается как количество полных лет между значением в поле DR(дата рождения) и DATE_1(дата начала лечения))
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.Age<0 and c.Age>3
--значение в теге DET как на уровне случая, так и на уровне медуслуг (если присутствуют) должно быть равно 1
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.IsChildTariff=0

insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
where r.IsChild=1 and m.IsChildTariff=0
---Если поле NOVOR=0, то недолжно быть ни какой информации о сопровождающем лице
insert #tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile																   				
where r.IsChild=0 AND EXISTS(SELECT * FROM t_RegisterPatientAttendant pa WHERE p.id=pa.rf_idRegisterPatient)





--ID_C
--дубликаты по ID_C
insert #tError
select distinct c1.id,71
from (
		select c.id,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
		where a.rf_idFiles=@idFile
		) c1 inner join (
							select c.GUID_Case
							from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join t_Case c on
										r.id=c.rf_idRecordCase
							where a.rf_idFiles=@idFile		
							group by c.GUID_Case
							having COUNT(*)>1
						) c2 on c1.GUID_Case=c2.GUID_Case
--USL_OK
--Проводится проверка на соответствие представленного значения справочнику V006
insert #tError
select distinct c.id,541
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV006 f on
			c.rf_idV006=f.ID
where f.ID is null						
--Если сроки лечения не принадлежат ни одному периоду оплаты из средств ОМС заявленных условия оказания
insert #tError
select distinct c.id,63
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join vw_sprV006 f on
			c.rf_idV006=f.ID
where f.DateBeg>c.DateBegin	

insert #tError
select distinct c.id,63
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join vw_sprV006 f on
			c.rf_idV006=f.ID
where f.DateEnd<c.DateEnd
--Если код законченного случая в представленном случае не соответствует заявленным условиям оказания, 
--или хотя бы одна из услуг не может быть оказана в заявленных условиях оказания.
--2012-11-14
insert #tError
select distinct c.id,541
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
						inner join vw_MeduslugiMes m  on
			c.id=m.rf_idCase
						left join OMS_NSI.dbo.V_MUCondition con on
			c.rf_idV006=con.ConditionCode
			and m.MUCode=con.MUCode
where con.MUCode is null											
--VIDPOM
--2013-06-18 только для ЗС
insert #tError
select distinct c.id,542
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.IsCompletedCase=1
						left join vw_sprV08 f on
			c.rf_idV008=f.ID
where f.ID is null
---2015-01-30 Проверка на соответствие Код ЗС+КСГ и виду медицинской помощи. проверка была пропущенна мною, по каким то не известным причинам.
insert #tError
select distinct c.id,542
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.IsCompletedCase=1
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase						
WHERE NOT EXISTS(SELECT * FROM dbo.vw_sprMUUnionV008 WHERE MU=m.MES AND V008=c.rf_idV008) 

--NPR_MO
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprT001 l on
			c.rf_idDirectMO=l.mcod
where c.rf_idDirectMO is not null and l.CodeM is null
--поле должно быть заполнено обязательно, при условии USL_OK=1  и EXTR=1 
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.HopitalisationType=1 and c.rf_idV006=1 and c.rf_idDirectMO is null
--поле должно быть заполнено обязательно, если в теге USL присутствует хотя бы одна из услугиз справочника vw_sprMUForDirectMU 
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUForDirectMU mu ON
			m.MUCode=mu.MU			
where c.rf_idDirectMO is null
/*
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and m.MUCode in ('60.2.1')
where c.rf_idDirectMO is null
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and m.MUCode in ('60.2.2')
where c.rf_idDirectMO is null
*/
--EXTR
insert #tError
select distinct c.id,544
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
where c.HopitalisationType<1 and c.HopitalisationType>2
--поле должно быть заполнено обязательно, при условии USL_OK=1 
insert #tError
select distinct c.id,544
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
where c.HopitalisationType is null and c.rf_idV006=1

--поле должно быть пустым, при условии USL_OK!=1 
insert #tError
select distinct c.id,544
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
where c.HopitalisationType IS not null and c.rf_idV006>1

--LPU
--соответствия кода медицинской организации реестровому номеру медицинской организации, указанному в теге CODE_MO,
insert #tError
select distinct c.id,545
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprT001 l on
			a.rf_idMO=l.mcod				
			and c.rf_idMO=l.CodeM		
where l.CodeM is null
--соответствия заявленного значения коду медицинской организации, указанному в имени файла.
insert #tError
select distinct c.id,545
from t_File f inner join t_RegistersCase a on
			f.id=a.rf_idFiles
			and f.id=@idFile 
						inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where f.CodeM<>c.rf_idMO
--PROFIL
insert #tError
select distinct c.id,546
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV002 v on
			c.rf_idV002=v.id
where v.id is null
--2014-02-13
--соответствие профиля оказанной медицинской помощи профилю, установленному для этого кода законченного случая в Справочнике медицинских услуг и их тарифов, 
--с учетом детских и взрослых профилей
insert #tError
select distinct c.id,556
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd	
						inner join dbo.t_MES m on
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUCompletedCase s ON
			m.MES=s.MU
						left join (SELECT * FROM vw_sprMuProfilPaymentByAge) v on
			c.IsChildTariff=v.Age
			AND c.rf_idV002=v.ProfileCode
			and m.MES=v.MUCode
where v.MUCode is null
---557
--4.	по дате окончания лечения проводится проверка на правомочность применения медицинской организацией указанного кода законченного случая. Проверка проводится в соответствии со справочником разрешенных к применению медицинских услуг
---------------11.04.2014 disable---------------
insert #tError
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join (SELECT * FROM dbo.vw_sprCompletedCaseMUDate UNION ALL SELECT * FROM dbo.vw_sprCSGValid ) t1 on
			c.rf_idMO=t1.CodeM
			AND mes.MES=t1.MU
			and c.DateEnd>=t1.DateBeg
			and c.DateEnd<=t1.DateEnd
where t1.MU is null
--	если на  дату окончания лечения медицинская услуга не разрешена к применению данному медицинскому учреждению
---------------26.03.2013 disable---------------
insert #tError				
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.IsCompletedCase=0
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase				
where NOT EXISTS(SELECT * FROM dbo.vw_sprNotCompletedCaseMUDate t1 WHERE t1.CodeM=c.rf_idMO AND t1.MU=mes.MUCode and t1.DateBeg <=c.DateEnd and t1.DateEnd>=c.DateEnd)
--эта проверка заменяет вышестоящие два скрипта
--проверка по медицинским услугам
--Date enable is 08.02.2013
--Изменил т.к. в справочнике ТФОМС может и не быть значения.Хотя считаю что это неправильно.
/*	  
Заменил данную проверку 20.10.2014
insert #tError
select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.IsCompletedCase=0
						inner join vw_sprMUAll mu on
			m.MUCode=mu.MU
						left join vw_sprMuProfilPaymentByAge v on
			--m.rf_idV002=isnull(v.ProfileCode,c.rf_idV002)
			c.rf_idV010=ISNULL(v.PaymentMethodCode,c.rf_idV010)
			--and c.IsChildTariff=v.Age
			and m.MUCode=v.MUCode
where v.MUCode is null
*/
INSERT #tError
select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
   a.id=r.rf_idRegistersCase
   and a.rf_idFiles=@idFile 
      inner join t_PatientSMO s on
   r.id=s.ref_idRecordCase
      inner join t_Case c on
   r.id=c.rf_idRecordCase 
   and c.DateEnd>='20121101'
      inner join t_Meduslugi m on
   c.id=m.rf_idCase
   and c.IsCompletedCase=0
   AND m.Price>0
      inner join vw_sprMUAll mu on
   m.MUCode=mu.MU      
where NOT EXISTS(SELECT * FROM vw_sprMuProfilPaymentByAge WHERE MUCode=m.MUCode AND PaymentMethodCode IS NOT null AND PaymentMethodCode=c.rf_idV010 )
 

--проверка по законченным случаям
--Заменил новой проверкой 20.10.2014 старая работала медленее. Данная проверка не активна на случаях КСГ т.к. нету справочника соответствий.
/*
insert #tError
select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
			and c.IsCompletedCase=1
						inner join t_MES m on
			c.id=m.rf_idCase
						inner join vw_sprMUAll mu on
			m.MES=mu.MU
						left join vw_sprMuProfilPaymentByAge v on
			--c.rf_idV002=isnull(v.ProfileCode,c.rf_idV002)
			c.rf_idV010=v.PaymentMethodCode
			--and c.IsChildTariff=v.Age
			and m.MES=v.MUCode
where v.MUCode is null	*/
insert #tError
select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
			and c.IsCompletedCase=1
						inner join t_MES m on
			c.id=m.rf_idCase
						inner join vw_sprMUAll mu on
			m.MES=mu.MU			
where NOT EXISTS(SELECT * FROM vw_sprMuProfilPaymentByAge WHERE MUCode=m.MES AND PaymentMethodCode IS NOT null AND PaymentMethodCode=c.rf_idV010 )

--DET
insert #tError
select distinct c.id,547
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age>17 and c.IsChildTariff=1

insert #tError
select distinct c.id,547
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age<18 and c.IsChildTariff=0

insert #tError
select distinct c.id,571
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.IsChildTariff<>m.IsChildTariff
where a.rf_idFiles=@idFile
--NHISTORY
insert #tError
select distinct c.id,548
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
where a.rf_idFiles=@idFile and len(ltrim(c.NumberHistoryCase))<1
--DATE_1
--дата начала лечения должна принадлежать текущему или предыдущему году
insert #tError
select c.id,549
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
where c.DateBegin>c.DateEnd
--DATE_2
--дата окончания лечения должна принадлежать отчетному периоду, указанному в реквизитах счета 
insert #tError
select c.id,55
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
where c.DateEnd<@dateStart or c.DateEnd>=@dateEnd

insert #tError
select c.id,550
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
where c.DateEnd>a.DateRegister
--проверяется участие медицинской организации в системе ОМС в течение всего срока лечения
--но перед этим объединяем интервалы участия МО в системе ОМС
DECLARE @tmpOMS AS TABLE (mcod CHAR(6), DateBegin DATE, DateEnd DATE)
IF (SELECT COUNT(*) FROM vw_sprLPUInOMS WHERE mcod=@mcod)>1
BEGIN
	;WITH sprPeriod AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY mcod,DateBegin) AS ROWID,mcod ,DateBegin,(DateEnd-1)  AS DateEnd
		FROM vw_sprLPUInOMS 
		WHERE mcod=@mcod
	)
	INSERT @tmpOMS
	SELECT a.mcod, a.DateBegin,a1.DateEnd
	FROM sprPeriod a INNER JOIN sprPeriod a1 ON
				a.mcod=a1.mcod
				AND a.RowId<>a1.ROWID
				AND a.DateBegin<=a1.DateEnd
END
ELSE 
BEGIN 
 INSERT @tmpOMS( mcod ,DateBegin ,DateEnd)
 SELECT mcod,DateBegin,DateEnd FROM vw_sprLPUInOMS WHERE mcod=@mcod 
END	


insert #tError
select c.id,551
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
					AND c.DateEnd>=@dateStart
					AND c.DateEnd<=@dateend
where NOT EXISTS(SELECT * FROM @tmpOMS WHERE mcod=a.rf_idMO and c.DateBegin>=DateBegin AND c.DateEnd<=DateEnd)  
--------------------------------------------------------------------------------------------------------------------------------
--проверяем для данного МО включать эту проверку или нет.
--Если typePR_NOV=0 то проверка для новых случаев, если typePR_NOV=1 то проверка для исправленных случаев
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
--Это если запись подается впервые
	insert #tError
	select c.id,50
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join sprCalendarPR_NOV0 cal on
				a.ReportMonth=cal.ReportMonth
				and a.ReportYear=cal.ReportYear
	where GETDATE()>=(case when c.DateEnd>=isnull(cal.ReportDate1,'20221231') and c.DateEnd<=isnull(cal.ReportDate2,'20221231') 
								then isnull(cal.ControlDate2,'20221231') else isnull(cal.ControlDate1,'20221231') end)
end 
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=1)
begin
--Если запись пришла как исправленная
--если в прошлый раз она подовалась не в срок, то отдаем с ошибкой 50
--Включил проверку 09.12.2015 в связи повышением тарифов на ноябрь
	insert #tError
	select c1.id,50
	from(
		select c.id,max(c1.id) as MaxID
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
					and r.IsNew=1
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join t_Case c1 on
				c.GUID_Case=c1.GUID_Case
				and c.id<>c1.id
		group by c.id
		 ) c1 inner join t_ErrorProcessControl e on
				c1.MaxID=e.rf_idCase
				and e.ErrorNumber=50
	
				
--если ошибка была 57 то на данный случай не накладываем услоивия контроля дат
--все остальные повторно выставленные случаи проверяем повторно на график выставления случаев
declare @dateAdd tinyint,
		@dateNow date=getdate()
--вычисляем кол-во дней на исправление неправильных записей
select @dateAdd=spr.ControlDateDay
from t_RegistersCase a inner join sprCalendarPR_NOV1 spr on
		a.ReportYear=spr.ReportYear
		and a.rf_idFiles=@idFile

--изменил 28.04.2014
INSERT #tError
SELECT c1.id,50
FROM(
		SELECT TOP 1 WITH ties c.id,c1.id AS id2,cb.TypePay,fb.DateCreate
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
							and r.IsNew=1
										inner join t_Case c on
							r.id=c.rf_idRecordCase
										inner join t_Case c1 on
						c.GUID_Case=c1.GUID_Case
						and c.id<>c1.id
										inner join t_RecordCaseBack rb on
						c1.id=rb.rf_idCase
										inner join t_CaseBack cb on
						rb.id=cb.rf_idRecordCaseBack
						--and cb.TypePay=2
										inner join t_RegisterCaseBack ab on
						rb.rf_idRegisterCaseBack=ab.id
										inner join t_FileBack fb on
						ab.rf_idFilesBack=fb.id								
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	
) c1
where NOT EXISTS(select * from t_ErrorProcessControl e where ErrorNumber IN (57,513) AND e.rf_idCase=c1.id2) 
		AND @dateNow>cast(DATEADD(DAY,@dateAdd,c1.DateCreate) as date) AND c1.TypePay=2

end
--Если период лечения не принадлежит ни одному из периодов наличия у медицинской организации лицензии на представленные условия оказания медицинской помощи, вид медицинской помощи и профиль
--Проверка не работает т.к. нету справочников

--DS01
--Сверка на справочник. Не реализованна проверка на сроки
insert #tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS1=(mkb.DiagnosisCode)
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null
--на соответствие диагноза из ОМС
insert #tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase
								left join vw_sprMKB10InOMS mkb on
					d.DS1=(mkb.DiagnosisCode)
					and c.DateEnd>=mkb.DateBeg
					and c.DateEnd<=mkb.DateEnd
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null

--DS0 DS2   DS3
insert #tError
select t.id,t.Error
from (
		select distinct c.id,552 as Error
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS0 FROM dbo.t_Diagnosis WHERE TypeDiagnosis>1) d on
					c.id=d.rf_idCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS0=mkb.DiagnosisCode
		where a.rf_idFiles=@idFile and d.DS0 is not null and mkb.DiagnosisCode is null		
	 ) t
	 
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
	  ) t left join (SELECT MU FROM dbo.vw_sprMUCompletedCase UNION ALL SELECT code FROM vw_sprCSG) t1 on
			t.MUCode=t1.MU
where t1.MU is NULL
--Если в теге USL при стационарной помощи присутствуют услуги отличные от A16 
--04.01.2014 при ЗС простовляются медуслуги в таблицу t_Meduslugi
insert #tError
select c.id,554
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.rf_idV006=1
						inner join t_MES mes on
				c.id=mes.rf_idCase		
							INNER JOIN t_Meduslugi m on									
				mes.rf_idCase=m.rf_idCase
				AND m.MUCode NOT IN (SELECT IDRB FROM OMS_NSI.dbo.V001)
WHERE NOT EXISTS(SELECT code FROM dbo.vw_sprCSG WHERE code=mes.MES UNION ALL SELECT MU_P FROM vw_sprMUCompletedCase WHERE MU=mes.MES) 
/*
--если код медицинской услуги  не соответствует кодам из Справочника медицинских услуг и их тарифов с учетом профиля, то выдаем ошибку 554
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
where m.Price>0 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMuProfilPaymentByAge WHERE Age=c.IsChildTariff AND ProfileCode=c.rf_idV002 AND MUCode=m.MUCode)
*/

--Проверка заполнености тега USL. Он должен быть заполнен при CODE_MES1=2.78.*
--01.04.2013
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU
							left join t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
where m.id is NULL
--для амбулаторных условий и кодов ЗС из групп 70.*, 72.* могут быть представлены услуги НЕ ТОЛЬКО  из класса 2.3,
--но хотя бы одна из услуг должна быть из класса 2.3.*,
-- но не могут быть представлены услуги из класса 2.60.*
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
where m.MUCode LIKE '2.60.%'
UNION ALL
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase													
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase				 				
where m.MUCode LIKE '2.60.%' AND c.rf_idV006=3	AND EXISTS(SELECT * FROM dbo.t_MES WHERE MES NOT LIKE '2.78.%' AND rf_idcase=c.id)
--проверяем есть ли услуги из класа 2.3.*
--Добавленна новая проверка 01.02.2014
--Изменил проверку 17.10.2014
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72										
										) mc on
				mes.MES=mc.MU			
where NOT EXISTS (SELECT DISTINCT rf_idCase from t_Meduslugi m1 WHERE m1.MUCode LIKE '2.3.%' AND m1.rf_idCase=c.id)


--------------------------------------------------09/04/2013--------------------------------------------------
-------Проверка на наличие медуслуг 2.3.* при ЗС=2.78.* 
-------c 2014 могут буть только услуги 2.60.*
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear<2014
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase							
WHERE m.MUCode NOT LIKE '2.3.%'

insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2013 AND a.ReportYear<2016
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode NOT LIKE '2.60.%'
 --Since 2016-0-18 We can use 57.* with 2.78.*
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode NOT LIKE '57.%'

insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode LIKE '57.%' AND EXISTS(SELECT * FROM dbo.t_Meduslugi m1 WHERE m1.MUCode LIKE '2.60.%' AND m1.rf_idCase=c.id)

insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				AND a.ReportYear>2015
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78																	
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode LIKE '2.60.%' AND EXISTS(SELECT * FROM dbo.t_Meduslugi m1 WHERE m1.MUCode LIKE '57.%' AND m1.rf_idCase=c.id)

-----если представлены услуги из класса 2.3.*, 2.60.*  а на уровне случая отсутствует код законченного случая по соответствующим условиям оказания 
----С 13.05.2015 услуга 2.3.* Без ЗС. Надо проверять, если есть услуга 2.90.* то может быть и 2.3.*
insert #tError
SELECT DISTINCT c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN vw_sprMU mu ON
				m.MUCode=mu.MU
									LEFT JOIN t_MES mes ON 
							c.id=mes.rf_idCase
WHERE mu.MUGroupCode=2 AND mu.MUUnGroupCode=60 /*IN (3,60)*/ AND mes.rf_idCase IS NULL	--AND c.rf_idV006=3
UNION ALL 
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN vw_sprMU mu ON
				m.MUCode=mu.MU
									LEFT JOIN t_MES mes ON 
							c.id=mes.rf_idCase
WHERE mu.MUGroupCode=2 AND mu.MUUnGroupCode=60 /*IN (3,60)*/  AND mes.rf_idCase IS NULL	AND c.rf_idV006<>3


-------Проверка на наличие медуслуг 55.1.* при условие оказания - дневной стационар
---------23.01.2015 так же могут быть услуги из справочника V001( объеденил медуслуги и номенклатуру)
/*
до 23.01.2015
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase				
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE c.DateEnd>='20130401' AND c.rf_idV006=2 AND m.MUCode NOT LIKE '55.1.%'	
*/
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase				
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE c.DateEnd>='20130401' AND c.rf_idV006=2 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMUUnionV001 WHERE MU=m.MUCode)
-------если представлены услуги из класса 55.1.*, а на уровне случая отсутствует код законченного случая по соответствующим условиям оказания 
/*
23.01.2015
второй скрипт лишний в данном объединение
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							left join t_MES mes on
				c.id=mes.rf_idCase				
WHERE c.DateEnd>='20130401' AND m.MUCode LIKE '55.1.%' AND mes.rf_idCase IS null	
UNION ALL
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							left join t_MES mes on
				c.id=mes.rf_idCase				
WHERE c.DateEnd>='20130401' AND c.rf_idV006<>2 AND m.MUCode LIKE '55.1.%' AND mes.rf_idCase IS NULL 
*/
insert #tError
select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUUnionV001 v ON
				m.MUCode=v.MU							
WHERE c.DateEnd>='20130401' AND NOT EXISTS(SELECT * FROM t_MES mes WHERE rf_idCase=c.id)
--------------------------------Новые проверки от 23.01.2015------------------
-- к 1.11.1 добваляется услуга 1.11.2 с 2015 года
insert #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join (SELECT rf_idRecordCase,id,rf_idV010 from t_Case WHERE rf_idV010<>32 AND rf_idV002!=158 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER JOIN (VALUES('1.11.1'),('1.11.2') ) v(MU) ON
			m.MUCode=v.mu			
WHERE  c.rf_idV010<>33
--23.01.2015
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
WHERE m.MUCode='1.11.2' AND c.rf_idV010<>32 AND c.rf_idV002<>158

INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
WHERE m.MUCode='55.1.5' AND c.rf_idV010<>34 AND c.rf_idV008<>32

insert #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.1')

insert #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV002=158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.2')


insert #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV010=32 AND c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.1')
-------------06.02.2015---------------
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV002<>158 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
													 WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV002=158 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
													 WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.2')
													 
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV010=32 AND c.rf_idV002<>158 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
																	  WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')
INSERT #tError
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=58 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
																	  WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.2')

-------------------------18.01.2016-----------------------------------------------------
--Поле заполняется 0 в одном из следующих случаев:
--•	в поле COMENTU указано ОТКАЗ,
--•	DATE_IN< DATE_1
--•	Значение в поле LPU на уровне случая не равно значению в теге LPU для услуги.

INSERT #tError
select distinct c.id,514
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
WHERE m.rf_idDoctor IS NULL AND (m.DateHelpBegin>=c.DateBegin OR m.rf_idMO=c.rf_idMO OR UPPER(ISNULL(m.Comments,'bla-bla'))<>'ОТКАЗ')
-------------------------18.01.2016-----------------------------------------------------

/*
31.10.2013 новая проверка
если при проверке соответствия услуг с ненулевым тарифом параметру в номере счета обнаруживается, 
что в случае представлены услуги с ненулевым тарифом, для которых параметры в номере счета различаются, то выдается ошибка 595 
*/

;WITH Case_CTE(id,AccountParam)
AS
(
select DISTINCT c.id,l.AccountParam
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND c.IsCompletedCase=0
						AND c.DateEnd>=@dateStart 
								inner join dbo.t_Meduslugi m on
						c.id=m.rf_idCase  						
								INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MUCode=l.MU
WHERE m.Price>0 and l.AccountParam IS NOT NULL			
)
INSERT #tError
SELECT c1.id,595
FROM Case_CTE c1 INNER JOIN Case_CTE c2 ON
		c1.id=c2.id
		AND c1.AccountParam<>c2.AccountParam
-------------------Новые проверки 23.01.2015----------------------		
---тег CODE_MES1 должен быть заполнен обязательно при IDSP=32,33,43
insert #tError
select distinct c.id,501
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN (VALUES (33),(43),(32)) v010(id) ON
			c.rf_idV010=v010.id					
WHERE NOT EXISTS(SELECT * FROM dbo.t_MES m WHERE m.rf_idCase=c.id)

---в обязательном порядке должен присутствовать составной тег USL (один или несколько), 
--содержащий сведения о нахождении пациента в профильном отделении стационара. 
--Причем хотя бы в одном из составных тегов USL  в обязательном порядке должны быть представлены услуги с кодом 1.11.1 
--(значение простого тега CODE_USL в составном теге USL должно быть равно 1.11.1 или 1.11.2).  
--В других составных тегах могут быть представлены только сведения об услугах из класса А16 номенклатуры медицинских услуг. 
--Т.е. в разделах «Сведения об услугах» для случая, в котором IDSP=16, могут быть представлены только услуги 1.11.1 или услуги из класса А16.
--23.01.2015

insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=33 AND NOT EXISTS(SELECT * 
									FROM dbo.t_Meduslugi m INNER JOIN (VALUES('1.11.1'),('1.11.2') ) v(MU) ON
													m.MUCode=v.mu	
									WHERE m.rf_idCase=c.id )
 --23.01.2015
insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 					
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUAll mu ON
			m.MUCode=mu.MU
			AND mu.IsCompletedCase=0			
WHERE c.rf_idV010=33 AND NOT EXISTS(SELECT * FROM (VALUES('1.11.1'),('1.11.2') ) v(MU) WHERE v.MU=m.MUCode )

/*
в обязательном порядке должен присутствовать составной тег USL (один или несколько), 
содержащий сведения о нахождении пациента в профильном отделении дневного стационара. 
Причем хотя бы в одном из составных тегов USL  в обязательном порядке должны быть представлены услуги из класса 55.1.*.  
В других составных тегах могут быть представлены только сведения об услугах из Номенклатуры медицинских услуг V001. 
Т.е. в разделах «Сведения об услугах» для случая, в котором IDSP= 43, 
могут быть представлены только услуги из класса 55.1.*  или услуги из Номенклатуры медицинских услуг V001.
*/
insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=43 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUCode LIKE '55.1.%')

INSERT #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=43 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
													 WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode NOT LIKE '55.1.%')

---27.02.2014
--в обязательном порядке должен присутствовать составной тег USL (один или несколько), содержащий сведения о нахождении пациента в профильном отделении стационара. Причем:
--если PROFIL=158 в теге SLUCH, то в теге USL должна быть представлена только услуга с кодом 1.11.2,
--если PROFIL<>158 в теге SLUCH, то в теге USL должна быть представлена услуга с кодом 1.11.1 и могут быть представлены услуги из Номенклатуры медицинских услуг V001
insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.1')

insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.2')
--проверяем соответствие кода КСГ и диагноза
--23.01.2015 способ оплаты может быть не только 33, но и 43
insert #tError
select distinct c.id,503
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
						INNER JOIN vw_sprCSGTherapyMKB s ON
			m.MES=s.code
						INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1					
						INNER JOIN (VALUES (33),(43)) v010(id) ON
			c.rf_idV010=v010.id		
WHERE NOT EXISTS(SELECT * FROM dbo.vw_sprCSGTherapyMKB csg WHERE csg.code=m.MES AND csg.MKBCode=d.DiagnosisCode)



--проверяем соответствие кода КСГ и хирургической операции
insert #tError
select distinct c.id,503
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
						INNER JOIN vw_sprCSGSurgery s ON
			m.MES=s.code										   
WHERE NOT EXISTS(SELECT * 
				 FROM dbo.t_Meduslugi m INNER JOIN dbo.vw_sprCSGSurgery csg ON
						m.MUCode=csg.CodeMU
				 WHERE m.rf_idCase=c.id)

---------------------------------------------503-----------------------------------------
--23.01.2015 IDSP=43 добавился новый способ оплаты
CREATE TABLE #tCSG (rf_idCase BIGINT,CSG VARCHAR(20),CodeMU VARCHAR(20))

INSERT #tCSG( rf_idCase, CSG, CodeMU )
select distinct c.id,MES,mu.MUCode
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN (VALUES (33),(43)) v010(id) ON
			c.rf_idV010=v010.id		
						INNER JOIN vw_sprCSGSurgery s ON
			m.MES=s.code
						INNER JOIN dbo.t_Meduslugi mu ON
			c.id=mu.rf_idCase
			AND mu.MUCode<>'1.11.1'


insert #tError
SELECT t.rf_idCase,503 
FROM #tCSG t left JOIN (SELECT rf_idCase FROM #tCSG a WHERE EXISTS(SELECT * FROM dbo.vw_sprCSGSurgery csg WHERE csg.code=a.CSG AND csg.CodeMU=a.CodeMU) )t1 ON
		t.rf_idCase=t1.rf_idCase		
WHERE t1.rf_idCase IS NULL

DROP TABLE #tCSG

-----------------------------------------------------------------------------------------
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
WHERE c.rf_idV010=33  AND mu.Quantity<>mu.CSGQuantity
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
WHERE c.rf_idV010=43  AND mu.Quantity>mu.PacientQuantity

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
		WHERE c.rf_idV010=43
		GROUP BY c.id,(CASE WHEN c.DateBegin=c.Dateend THEN 1 ELSE DATEDIFF(d,c.DateBegin,c.DateEnd)+1 END ) 
	) c
WHERE c.QuantityCase<>c.MUQuantity
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
---	сверка основного DS,PROFIL,PRVS в случаях и медуслугах для IDSP=33 and 43
--06.02.2015
INSERT #tError
select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd													
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
								INNER JOIN (VALUES (33),(43)) v010(id) ON
					c.rf_idV010=v010.id	
WHERE c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode
																			AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)
/*
если VIDPOM=32 и IDSP=32, то проводится проверка корректности оформления случая оказания медицинской помощи, 
оплачиваемого по законченному случаю. А именно, значения в тегах DS1, PROFIL, PRVS, 
представленные в разделе «Сведения о случае» (составной тег SLUCH) должны быть соответственно равны значениям в тегах DS, PROFIL, PRVS, 
представленным хотя бы в одном из разделов «Сведения об услуге» (составной тег USL),  
вне зависимости представлены в составном теге USL сведения о койко-днях с кодом 1.11.* или сведения о проведенных оперативных вмешательствах.
*/																			
INSERT #tError
select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd													
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
														WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')		
	

/*
По медуслугам или кодам законченных случаев определяется параметр в номере счета, 
в котором впоследствии должен быть представлен случай. 
По заранее установленному соответствию параметров номеров счетов и кодов результатов обращения 
(заранее организованная таблица) определяются коды результатов обращения, которые должны присутствовать в случае.  
Если в случае представлен код результата обращения, 
который не соответствует установленному по медуслугам или коду законченного случая параметру выдается ошибка 596(ТК1).
*/
INSERT #tError
select DISTINCT c.id,596
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase							
						AND c.DateEnd>=@dateStart 
								inner join dbo.t_Meduslugi m on
						c.id=m.rf_idCase  						
								INNER JOIN dbo.vw_sprMuWithParamAccount l ON
						m.MUCode=l.MU
						AND m.Price>0
						AND l.AccountParam IS NOT NULL
							INNER JOIN OMS_NSI.dbo.sprRefAccountLetterV009 v009 ON
						l.AccounttypeId=v009.AccountTypeId
WHERE c.rf_idV009 NOT in (SELECT rf_idV009 FROM OMS_NSI.dbo.sprRefAccountLetterV009 v WHERE v.AccountTypeId=l.AccountTypeId )
UNION 
select DISTINCT c.id,596
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase							
						AND c.DateEnd>=@dateStart 
								inner join dbo.t_MES m on
						c.id=m.rf_idCase  						
								INNER JOIN (SELECT MU,AccountParam,AccountTypeId from dbo.vw_sprMuWithParamAccount 
											UNION ALL 
											SELECT MU,AccountParam,AccountTypeId from dbo.vw_sprCSGWithParamAccount) l ON
						m.MES=l.MU
								INNER JOIN OMS_NSI.dbo.sprRefAccountLetterV009 v009 ON
						l.AccounttypeId=v009.AccountTypeId
WHERE c.rf_idV009 NOT in (SELECT rf_idV009 FROM OMS_NSI.dbo.sprRefAccountLetterV009 v WHERE v.AccountTypeId=l.AccountTypeId )
---Test 597 
--- 05.11.2013
/*
проверка на правомочность проведения диспансеризации определенных групп взрослого населения, 
профилактических осмотров взрослого населения, профилактических осмотров несовершеннолетних (далее - Диспансеризация)
*/
DECLARE @dateStartLicense DATE
SELECT @dateStartLicense=DateStart FROM sprLPULicense WHERE CodeM=@codeLPU

INSERT #tError( rf_idCase, ErrorNumber )
SELECT DISTINCT t.id,597
FROM (
		select DISTINCT c.id,c.DateBegin,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile
										inner join t_Case c on
								r.id=c.rf_idRecordCase							
								AND c.DateEnd>=@dateStart 
										inner join dbo.t_Meduslugi m on
								c.id=m.rf_idCase  						
										INNER JOIN dbo.vw_sprMuWithParamAccount l ON
								m.MUCode=l.MU
								AND m.Price>0
								AND l.AccountParam IS NOT NULL	
										INNER JOIN (VALUES( 'F'),('O'),('R') ) v(Letter) ON
								l.AccountParam=v.Letter
		UNION ALL
		select DISTINCT c.id,c.DateBegin,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile
										inner join t_Case c on
								r.id=c.rf_idRecordCase							
								AND c.DateEnd>=@dateStart 
										inner join dbo.t_MES m on
								c.id=m.rf_idCase  						
										INNER JOIN (SELECT MU,AccountParam from dbo.vw_sprMuWithParamAccount 
													UNION ALL 
													SELECT MU,AccountParam from dbo.vw_sprCSGWithParamAccount) l ON
								m.MES=l.MU	
										INNER JOIN (VALUES( 'F'),('O'),('R') ) v(Letter) ON
								l.AccountParam=v.Letter							
		) t
WHERE t.DateBegin<ISNULL(@dateStartLicense,'20200101')
ORDER BY t.id

-------Проверка на соответствие ЗС и возрасту(применяется для диспансеризации пока что)


/*	Изменения от 24.11.2014	
Изменения коснулись 72 класса медуслуг. Не все подкласы 72 должны высчитываться по стандартному алгоритму расчета полных лет пациента.
если в качестве кода ЗС используется код из группы 70.3*, 72.1.*, 72.2.*, 
то возраст рассчитывается как разность между годом начала лечения (Year(DATE_1)) и годом рождения,
*/
--23.01.2015
----проверка проводится для все случаев кроме тех у кого в поле Coments стоит 11 или 21
--не для всех кодов ЗС
---переделатьдля ЗС с кодом 72.2.*.
insert #tError
select c.id,592
FROM (
		SELECT c.id,mes.Mes,YEAR(c.DateBegin)-YEAR(p.BirthDay) AS Age,p.rf_idV005
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase	
								INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=3
											UNION ALL 
											SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=1
											/*UNION ALL 
											SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=2*/) mc on
						mes.MES=mc.MU
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
			) c	 INNER JOIN dbo.t_AgeMU2 s on
						s.MU=c.MES
WHERE NOT EXISTS(SELECT * FROM dbo.t_AgeMU2 s WHERE s.MU=c.MES AND s.Age=c.Age and ISNULL(s.Sex,c.rf_idV005)=c.rf_idV005)
/*Новая проверка в соответствии со служебной запиской №09-28 от 16.02.2015*/
--------------Для детей старше 3 лет--------------------
insert #tError
SELECT DISTINCT c.id,592
FROM (
		SELECT c.id,mes.Mes,YEAR(c.DateBegin)-YEAR(p.BirthDay) AS Age				
				,c.DateEnd,c.DateBegin
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase									
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
		WHERE mes.MES LIKE '72.2.%'
			) c	 INNER JOIN t_AgeMU72_2 s on
						s.MU=c.MES
WHERE s.TypeAge='y' AND	NOT EXISTS(SELECT * FROM t_AgeMU72_2 s WHERE s.MU=c.MES AND s.AgeStart=c.Age AND DATEDIFF(yyyy,c.DateBegin,c.DateEnd)=0)

-----------новорожденные----------------------
insert #tError
SELECT DISTINCT c.id,592
FROM (
		SELECT c.id,mes.Mes,datediff(d,p.BirthDay,c.DateBegin) AS AgeStartDay,datediff(d,p.BirthDay,c.DateEnd)	AS AgeEndDay
				,c.DateEnd,c.DateBegin
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase									
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
		WHERE mes.MES LIKE '72.2.%'
			) c	 INNER JOIN t_AgeMU72_2 s on
						s.MU=c.MES
WHERE s.TypeAge='d' AND	NOT EXISTS(SELECT * FROM t_AgeMU72_2 s WHERE s.MU=c.MES AND s.AgeStart<=c.AgeStartDay AND c.AgeEndDay<=s.AgeEnd)
-----------------и дети до 3 лет включительно----------------------
DECLARE @dt DATETIME=CAST(year(GETDATE()) AS CHAR(4))+'1231 23:59:59',
		@dt1 DATETIME=GETDATE()
		
insert #tError
select DISTINCT c.id,592
FROM (
		SELECT c.id,mes.Mes
		/*,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1 AS AgeStartDay
		,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1 AS AgeEndDay
		--убирался раньше один день т.к тип данных не datetime
		,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay))) AS AgeStartDay
		,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay))) AS AgeEndDay */
		,CASE WHEN c.DateBegin<>DATEADD(month,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1, p.BirthDay) 
						THEN  DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay))) 
						ELSE DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1 END AS AgeStartDay
		,CASE WHEN c.DateEnd<>DATEADD(month,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1, p.BirthDay) 
						THEN  DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay))) 
						ELSE DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1 END AS AgeEndDay
				,c.DateEnd,c.DateBegin
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase									
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
		WHERE mes.MES LIKE '72.2.%'
			) c	 INNER JOIN t_AgeMU72_2 s on
						s.MU=c.MES
WHERE s.TypeAge='m' AND	NOT EXISTS(SELECT *	FROM t_AgeMU72_2 s
								   WHERE s.MU=c.MES AND s.AgeStart<=c.AgeStartDay AND 
										c.AgeEndDay<=(CASE WHEN AgeEnd IS NULL THEN c.AgeStartDay + DATEDIFF(MONTH,@dt1,@dt)+SIGN(1+SIGN(DAY(@dt)-DAY(@dt1)))  ELSE AgeEnd END)
									)



--2 вариант,если в качестве кода ЗС используются коды из групп 70.5.*, 70.6.*, 72.3.*,  то возраст рассчитывается в обычном порядке (равен значению в поле AGE).
insert #tError
select c.id,592
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND ISNULL(c.Comments,N'10') NOT IN (N'11',N'21')
						inner join t_MES mes on
				c.id=mes.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=3
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=5
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=6
									) mc on
				mes.MES=mc.MU
						INNER JOIN dbo.vw_RegisterPatient p ON
				p.rf_idFiles=@idFile
				and r.id=p.rf_idRecordCase	
						INNER JOIN dbo.t_AgeMU2 s on
						s.MU=mes.MES	
WHERE NOT EXISTS(SELECT * FROM dbo.t_AgeMU2 s WHERE s.MU=mes.MES AND s.Age=c.Age AND ISNULL(s.Sex,p.rf_idV005)=p.rf_idV005)

---2013-06-18
insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=1
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=3
									) mc on
				mes.MES=mc.MU		
WHERE c.Comments IS NULL
--2013-06-19
insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join dbo.t_Meduslugi m on
				c.id=m.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode IN (84,90)) mc on
				m.MUCode=mc.MU		
WHERE c.Comments IS NULL

---2013-08-02
insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
						LEFT JOIN (VALUES('10'),('11'),('14'),('20'),('21')) v(t)	ON
				c.Comments=v.t
WHERE c.Comments IS NOT NULL AND v.T IS null			
---2013-06-25
insert #tError
select c.id,594
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.IsCompletedCase=1
						inner join t_MES mes on
				c.id=mes.rf_idCase							
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
						LEFT JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE (MUGroupCode=70 AND MUUnGroupCode=3) 
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE (MUGroupCode=72 AND MUUnGroupCode=1) 
									) mc on
				mes.MES=mc.MU		
WHERE m.Comments IS NOT NULL AND mc.MU IS NULL	
--2013-06-19
---Услуги 2.84.* не могут идти с законченым случаем.
-- На втором этапе диспансеризации ОТКАЗ от обследования не допустим.
--insert #tError
--select c.id,594
--from t_RegistersCase a inner join t_RecordCase r on
--				a.id=r.rf_idRegistersCase
--				and a.rf_idFiles=@idFile
--						inner join t_Case c on
--				r.id=c.rf_idRecordCase	
--				AND c.IsCompletedCase=0						
--						INNER JOIN dbo.t_Meduslugi m1 ON
--				c.id=m1.rf_idCase
--						LEFT join (SELECT DISTINCT rf_idCase from dbo.t_Meduslugi WHERE MUCode LIKE '2.84.%') m on
--				c.id=m.rf_idCase								
--WHERE m1.Comments IS NOT NULL AND m.rf_idCase IS NULL

insert #tError
select c.id,594
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join dbo.t_Meduslugi m on
				c.id=m.rf_idCase							
WHERE m.Comments IS NOT NULL AND m.Comments <>'ОТКАЗ'	

-----------------------------------------------------------------------------------------------------------------------------

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
	  ) t inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase UNION ALL SELECT code FROM vw_sprCSG) t1 on
			t.MUCode=t1.MU

--RSLT
insert #tError
select distinct c.id,559
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV009 v on
			c.rf_idV009=v.id
			and c.rf_idV006=v.USL_OK
where v.id is NULL
---запись в справочнике V009 должна быть действующей для текущей даты (даты регистрации реестра сведений)
--28.03.2014
insert #tError
select distinct c.id,559
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase					
where NOT EXISTS(SELECT * FROM vw_sprV009 WHERE id=c.rf_idV009 AND @dateReg>=DateBeg AND ISNULL(DateEnd,@dateReg)>=@dateReg)

--ISHOD
insert #tError
select distinct c.id,560
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV012 v on
			c.rf_idV012=v.id
			and c.rf_idV006=v.USL_OK
where v.id is null

--PRVS
insert #tError
select distinct c.id,561
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV004 v on
			c.rf_idV004=v.id
			AND c.DateEnd>=v.DateBeg
			AND c.DateEnd<v.DateEnd
where v.id is NULL

--15.04.2014 Отключил по причине того что в МО не уходят справочники соответствия МУ PRVS
--31.03.2015 Enable by Antonova's order.
--01.04.2015 Disable by Antonova's order.
 /*
insert #tError
select distinct c.id,562
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.IsCompletedCase=0	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Meduslugi m on
			c.id=m.rf_idCase						
						left join vw_sprMuPRVSAge v on
			m.rf_idV004=v.rf_idV004
			and m.IsChildTariff=v.IsChildTariff
			and m.MUCode=v.MUCode
where m.Price>0 and v.MUCode is null

insert #tError
select distinct c.id,562
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Mes m on
			c.id=m.rf_idCase
						inner join vw_sprMUCompletedCase mu on
			m.MES=mu.MU
						left join vw_sprMuPRVSAge v on
			c.rf_idV004=v.rf_idV004
			and c.IsChildTariff=v.IsChildTariff
			and m.MES=v.MUCode
where v.MUCode is null
*/ 
--если NOVOR <> 0, то проводится проверка на указание в поле OT_P значения «НЕТ» в Реестре пациентов (без учета регистра)
--данной проверки нету. она замененна 578
--insert #tError 
--select c.id, 563
--from t_RegistersCase a inner join t_RecordCase r on
--				a.id=r.rf_idRegistersCase
--				and a.rf_idFiles=@idFile
--							inner join t_RefRegisterPatientRecordCase rp on
--				r.id=rp.rf_idRecordCase
--							inner join t_RegisterPatient p on
--				rp.rf_idRegisterPatient=p.id
--				and p.rf_idFiles=@idFile														
--							inner join t_Case c on
--				r.id=c.rf_idRecordCase	
--							inner join t_RegisterPatientAttendant pa on
--				p.id=pa.rf_idRegisterPatient
--where r.IsChild=1 and c.IsSpecialCase=2 and pa.Ot is not null	  
------------------------------------------------------2013-05-01--------
insert #tError 
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
--проверка на корректность заполнения поля OS_SLUCH 
--- 1 вариант когда поле OS заполнено в справочнике
insert #tError 
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
insert #tError 
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
WHERE mc.IsSpecialCase IS NULL AND ISNULL(c.IsSpecialCase,2)<>2
---2013-08-05
-- проверка медуслуг
--Изменения от 20.10.2014 Необходимо проверять только медуслуги с ненулевым тарифом
insert #tError 
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
--отключил т.к. не правильный алгоритм
--insert #tError 
--select c.id, 563
--from t_RegistersCase a inner join t_RecordCase r on
--				a.id=r.rf_idRegistersCase
--				and a.rf_idFiles=@idFile																					
--							inner join t_Case c on
--				r.id=c.rf_idRecordCase	
--				AND c.IsCompletedCase=0
--							INNER JOIN t_Meduslugi m ON
--				c.id=m.rf_idCase
--							LEFT JOIN dbo.vw_sprMUNotCompletedCase mc ON
--				m.MUCode=mc.MU
--				AND ISNULL(c.IsSpecialCase,2)<>2
--WHERE mc.IsSpecialCase IS NOT NULL AND mc.MU IS null
------------------------------------------------------2013-05-01--------
--IDSP
insert #tError
select distinct c.id,564
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV010 v on
			c.rf_idV010=v.id
where v.id is null
--ED_COL
insert #tError
select mes.rf_idCase,565
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Quantity<>1		

insert #tError
select mes.rf_idCase,565
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Quantity is null
--TARIF
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff=0		
--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff is null

--определяется возраст (на дату начала лечения) пациента: если возраст меньше 18, то применяются детские тарифы, если возраст пациента не меньше 18, то применяются взрослые тарифы
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO=t1.CodeM
				AND c.rf_idV006=t1.rf_idV006
				and c.DateEnd>=t1.DateBegin
				and c.DateEnd<=t1.DateEnd
where t1.CodeM is null
-------------------------------------------------------для общих тариффов
insert #tError
select t.id,65
from (
		select c.id,mes.MES,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Tariff
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase
											 UNION ALL SELECT code FROM vw_sprCSG
											 ) m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>4
		) t left join (SELECT MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
					   UNION ALL 
					   SELECT MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff
					   ) mp on
				t.MES=mp.MU
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null
-------------------------------------------------------для индивидуальных тарифов

select c.id,mes.MES,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Tariff,c.rf_idMO
INTO #tmpCasePriceMES
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase 
											UNION ALL SELECT code FROM vw_sprCSG
											) m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4

INSERT #tError SELECT t.id,65
FROM #tmpCasePriceMES t																		
where NOT EXISTS( SELECT * FROM (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
								 UNION ALL 
								 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp  
				WHERE t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					  and t.DateEnd<=mp.MUPriceDateEnd and t.Tariff=mp.Price)     

DROP TABLE #tmpCasePriceMES
--TARIF
--Если в качестве услуги представлена хирургическая операция (класс А16 из Номенклатуры медицинских услуг), то тариф должен быть равен 0
insert #tError
select distinct c.id,65
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase	
						inner join oms_NSI.dbo.V001	vm on
			m.MUCode=vm.IDRB						
where m.Price<>0
--Проверка тарифов
--на дату окончания лечения определяется уровень оплаты для данного медицинского учреждения  и  представленного в случае условия оказания 
insert #tError
select mes.rf_idCase,65
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprPriceLevelMO t1 on
				c.rf_idMO=t1.CodeM
				AND c.rf_idV006=t1.rf_idV006
				and c.DateEnd>=t1.DateBegin
				and c.DateEnd<=t1.DateEnd
where t1.CodeM is null
--В Справочнике медицинских услуг и тарифов для данного медицинского учреждения (если уровень оплаты - индивидуальный), 
--кода медицинской услуги, возраста пациента, уровня оплаты осуществляется поиск действующего на дату окончания лечения тарифа и 
--производится сравнение с представленным значением
-------------------------------------------------------для общих тариффов

--Изменения 17.10.2014
INSERT #tError
select t.id,65
from (
  select c.id,mes.MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>4
	WHERE c.IsCompletedCase=0 AND mes.Price>0
  ) t     
where NOT EXISTS(SELECT * FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price ) 
-------------------------------------------------------для индивидуальных тарифов

select c.id,mes.MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price,c.rf_idMO
INTO #tmpCasePrice
from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_Meduslugi mes on
						c.id=mes.rf_idCase
								inner join vw_sprMU m on
						mes.MUCode=m.MU								
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4				
where c.IsCompletedCase=0 AND mes.Price>0

INSERT #tError SELECT t.id,65 FROM #tmpCasePrice t																		
where NOT EXISTS( SELECT * FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType
																		and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
																		and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price)     
DROP TABLE #tmpCasePrice

--PERIOD in vw_MSLoacation
--26.12.2013 Если период лечения не принадлежит ни одному из периодов наличия у медицинской организации лицензии на 
--представленные условия оказания медицинской помощи, вид медицинской помощи и профиль
/*		   Не использовать
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			and a.reportYear<2014
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE NOT EXISTS(SELECT * FROM vw_MSLocation 
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)
*/
						
------------------------------2014------------------------------------------
--11.04.2014

/* Объединяю периоды  т.к. в справочнике они не объеденены*/
DECLARE @tmpMSLocation AS TABLE (CodeM CHAR(6), DateBegin DATE, DateEnd DATE,rf_idV006 TINYINT,rf_idV008 SMALLINT, rf_idV002 SMALLINT)

IF EXISTS(SELECT CodeM,rf_idV002,rf_idV006,rf_idV008 
	FROM vw_MSLocation WHERE CodeM=@codeLPU GROUP BY CodeM,rf_idV002,rf_idV006,rf_idV008 HAVING COUNT(*)>1)
BEGIN
	;WITH sprPeriod1 AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY CodeM,DateBegin,rf_idV006,rf_idV008,rf_idV002) AS ROWID,CodeM,DateBegin,(DateEnd-1)  AS DateEnd,
				rf_idV006,rf_idV008,rf_idV002
		FROM vw_MSLocation 
		WHERE CodeM=@codeLPU
	)
	INSERT @tmpMSLocation
	SELECT a.CodeM, a.DateBegin,a1.DateEnd,a.rf_idV006,a.rf_idV008,a.rf_idV002
	FROM sprPeriod1 a INNER JOIN sprPeriod1 a1 ON
				a.CodeM=a1.CodeM
				AND a.rf_idV006=a1.rf_idV006
				AND a.rf_idV008=a1.rf_idV008
				AND a.rf_idV002=a1.rf_idV002
				AND a.RowId<>a1.ROWID
				AND a.DateBegin<=a1.DateEnd
END
--------------------------------------------------------------------------------
--кладем уникальные записи в таблицу по лицензиям
 INSERT @tmpMSLocation( CodeM,rf_idV002,rf_idV006,rf_idV008 ,DateBegin ,DateEnd)
 SELECT v.CodeM,v.rf_idV002,v.rf_idV006,v.rf_idV008 ,v.DateBegin,v.DateEnd
 FROM vw_MSLocation v INNER JOIN (SELECT CodeM,rf_idV002,rf_idV006,rf_idV008 
								  FROM vw_MSLocation 
								  WHERE CodeM=@codeLPU 
								  GROUP BY CodeM,rf_idV002,rf_idV006,rf_idV008 
								  HAVING COUNT(*)=1) t ON
			v.CodeM=t.CodeM
			AND v.rf_idV002=t.rf_idV002
			AND v.rf_idV006=t.rf_idV006
			AND v.rf_idV008=t.rf_idV008
 WHERE v.CodeM=@codeLPU 
/*--------------------------------------*/
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.IsCompletedCase=0
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUCode NOT LIKE '2.82.%'			
WHERE NOT EXISTS(SELECT * FROM @tmpMSLocation
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)

/*--------------------------------------*/
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			AND c.IsCompletedCase=1				
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
WHERE NOT EXISTS(SELECT * FROM @tmpMSLocation
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)
/*--------------------------------------*/						
-- алгоритм для случаев оказания амбулаторно-поликлинической помощи в приемном отделение стационара						
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.rf_idV006=3	
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUCode LIKE '2.82.%'			
WHERE NOT EXISTS(SELECT * FROM vw_MSLocation 
				 WHERE CodeM=@CodeLPU AND rf_idV006=1 AND rf_idV008=31 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)				
--SUMV
--если применен способ оплаты по законченному случаю,  то SUMV=TARIF и должна быть больше 0
insert #tError
select mes.rf_idCase,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff<>c.AmountPayment

--insert #tError
--select c.id,566
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase	
--where c.AmountPayment<=0 and c.Emergency is null
--если применен способ оплаты, отличный от способа оплаты по законченному случаю, то значение должно быть равно сумме стоимостей всех услуг
--(стоимость услуг равна произведению количества услуг на тариф одной услуги) и должна быть больше 0
insert #tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.IsCompletedCase=0
						left join dbo.t_Meduslugi m on
			c.id=m.rf_idCase
where a.rf_idFiles=@idFile
group by c.id,c.AmountPayment
having c.AmountPayment<>ISNULL(cast(SUM(m.Quantity*m.Price) as decimal(15,2)),0) 

insert #tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
where a.rf_idFiles=@idFile AND c.AmountPayment<=0 AND c.rf_idV006<>4
-----------------------------------------------------------------USL--------------------------------------------------------------
--ID_U
--дубликаты по ID_U
insert #tError
select distinct c1.id,568
from(
		select c.id,m.GUID_MU as ID_U
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join t_Meduslugi m on
					c.id=m.rf_idCase
		where a.rf_idFiles=@idFile
	) c1 inner join (
						select m.GUID_MU
						from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join t_Case c on																																	r.id=c.rf_idRecordCase
													inner join t_Meduslugi m on
								c.id=m.rf_idCase				
						where a.rf_idFiles=@idFile
						group by m.GUID_MU
						having COUNT(*)>1
					) c2 on c1.ID_U=c2.GUID_MU	
--LPU
--19.01.2016 Для тех МУ которые не в справочнике значения олжны совпадать.
insert #tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.rf_idMO<>m.rf_idMO
WHERE NOT EXISTS(SELECT * FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.MU=m.MUCode)
--Если МУ из справочника и признак 1 то на уровне медуслуг должен стоят код из этого справочника
insert #tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER join vw_sprMUAllowDiffrentCodeM mu ON
			m.MUCode=mu.MU                      
WHERE mu.IsOnlyMO=1 and NOT EXISTS(SELECT * FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.IsOnlyMO=1 AND mo.CodeM=m.rf_idMO)
--Если МУ из справочника и признак 0 то на уровне медуслуг должен стоят код из этого справочника или код выставившей МО
insert #tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER join vw_sprMUAllowDiffrentCodeM mu ON
			m.MUCode=mu.MU                      
WHERE mu.IsOnlyMO=0 and NOT EXISTS(SELECT 1 FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.IsOnlyMO=0 AND mo.CodeM=m.rf_idMO
									UNION ALL 
									SELECT 1 FROM dbo.t_Meduslugi mo WHERE mo.rf_idMO=m.rf_idMO
									)
----------------------------------------------------------------------------------------

--PROFIL
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						left join vw_sprV002 v on
			m.rf_idV002=v.id
where v.id is null						
---------------2014-02-04---------------
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			--and c.rf_idV002!=134	
						INNER JOIN dbo.vw_IsSpecialCase s ON
			c.IsSpecialCase=s.OS_SLUCH
			AND s.IsClinincalExamination=0
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002
--16.12.2013 добавил в представлени vw_idCaseWithOutPRVSandProfilCompare что проверка не производиться по КСГ
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002
/*
insert #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002
*/
--2014-02-27
INSERT #tError
select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join (SELECT rf_idRecordCase,id,rf_idV002,IsSpecialCase from t_Case WHERE rf_idV010<>33 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * from vw_idCaseWithOutPRVSandProfilCompare 
											  WHERE rf_idFiles=@idFile AND DateEnd>=@dateStart AND DateEnd<@dateEnd AND id=c.id)
---------------2013-06-24---------------
--DATE_IN

--Проверка 2: на дату начала услуги
--для не ЗС
insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.IsSpecialCase IS NULL
					AND c.IsCompletedCase=0
						inner join t_Meduslugi m on
			c.id=m.rf_idCase 
where c.DateBegin>m.DateHelpBegin
insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
						INNER JOIN dbo.vw_IsSpecialCase s ON
					c.IsSpecialCase=s.OS_SLUCH
					AND s.IsClinincalExamination=0
					AND c.IsCompletedCase=0
						inner join t_Meduslugi m on
			c.id=m.rf_idCase 
where c.DateBegin>m.DateHelpBegin
--для ЗС

insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.IsSpecialCase IS NULL
					AND c.IsCompletedCase=1
						INNER JOIN dbo.t_Mes mes ON
					c.id=mes.rf_idCase
						inner join t_Meduslugi m on
					c.id=m.rf_idCase 
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
					c.id=ce.id
					AND ce.rf_idFiles=@idFile				
where ce.id IS NULL AND c.DateBegin>m.DateHelpBegin

insert #tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
						INNER JOIN dbo.vw_IsSpecialCase s ON
					c.IsSpecialCase=s.OS_SLUCH
					AND s.IsClinincalExamination=0
					AND c.IsCompletedCase=1
						INNER JOIN dbo.t_Mes mes ON
					c.id=mes.rf_idCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase 
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
					c.id=ce.id
					AND ce.rf_idFiles=@idFile				
where ce.id IS NULL AND c.DateBegin>m.DateHelpBegin	

--DATE_OUT
--Проверка 2: на дату окончания услуги
insert #tError
select distinct c.id,573
from (
		select c.id
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
								inner join t_Case c on
							r.id=c.rf_idRecordCase	
								inner join t_Meduslugi m on
					c.id=m.rf_idCase 
		where m.DateHelpBegin>m.DateHelpEnd --or m.DateHelpEnd>c.DateEnd
		union all
		select c.id
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
								inner join t_Case c on
							r.id=c.rf_idRecordCase	
							AND c.IsSpecialCase IS NULL
								inner join t_Meduslugi m on
					c.id=m.rf_idCase 
		where m.DateHelpEnd>c.DateEnd
		UNION ALL
		select c.id
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
								inner join t_Case c on
							r.id=c.rf_idRecordCase	
								INNER JOIN dbo.vw_IsSpecialCase s ON
							c.IsSpecialCase=s.OS_SLUCH
							AND s.IsClinincalExamination=0
								inner join t_Meduslugi m on
					c.id=m.rf_idCase 
		where m.DateHelpEnd>c.DateEnd
	) c
--DS
insert #tError
select distinct c.id,574
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase								
						left join oms_NSI.dbo.sprMKB mkb on
			m.DiagnosisCode=mkb.DiagnosisCode
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null
--KOL_USL
insert #tError
select distinct c.id,575
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where m.Quantity<=0

insert #tError
select distinct c.id,575
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where Quantity-ROUND(Quantity,0)>0

--SUMV_USL
insert #tError
select distinct c.id,576
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where m.TotalPrice<>cast((m.Price*m.Quantity) as decimal(15,2))
--PRVS
insert #tError
select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						left join vw_sprV004 v on
			m.rf_idV004=v.id
			AND c.DateEnd>=v.DateBeg
			AND c.DateEnd<=v.DateEnd 
where v.id is null

---------------2014-02-04---------------
insert #tError
select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.vw_IsSpecialCase s ON
			c.IsSpecialCase=s.OS_SLUCH
			AND s.IsClinincalExamination=0
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						inner join vw_sprMU mu on
			m.MUCode=mu.MU
			LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
WHERE ce.id IS NULL and c.rf_idV004<>m.rf_idV004
------------2014-02-26
insert #tError
select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			AND c.IsSpecialCase IS NULL			
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						inner join vw_sprMU mu on
			m.MUCode=mu.MU
			LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
WHERE c.rf_idV002<>158 and ce.id IS NULL and c.rf_idV004<>m.rf_idV004

--------------------------------------------------------------------------------Проверка данных из файла с людьми-------------------------------------------------
--ID_PAC

--поиск дубликатов по ID_PAC в файле с людьми
insert #tError
select distinct c1.id,71
from(
		select c.id,r.ID_Patient
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase								
		where a.rf_idFiles=@idFile
	) c1 inner join (
					 select ID_Patient 
					 from t_RegisterPatient 
					 where rf_idFiles=@idFile
					 group by ID_Patient	
					 having COUNT(*)>1
					) c2 on c1.ID_Patient=c2.ID_Patient
--поиск не корректных значений в поле dbo.t_RegisterPatient.ID_Patient
insert #tError
select distinct c1.id,71
from(
		select c.id,r.ID_Patient
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase								
		where a.rf_idFiles=@idFile
	) c1 inner join (
					 select ID_Patient 
					 from t_RegisterPatient 
					 where rf_idFiles=@idFile and ID_Patient in ('','0')
					 group by ID_Patient	
					) c2 on c1.ID_Patient=c2.ID_Patient
--FAM
--Проверка того что не запонено фамилия сопровождающего при NOVOR=0
insert #tError 
select c.id as rf_idCase, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
						inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient								
where r.IsChild=0 

insert #tError 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Fam like '%[^-а-яА-Я"''. ]%'

insert #tError 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Fam IS NOT NULL AND  RTRIM(LTRIM(p.Fam)) like '[-"'']%'
--------------------
insert #tError 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Fam IS NULL

insert #tError 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Fam ='НЕТ'

--Проверка того что не запонено фамилия пациента при NOVOR=1
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=1 and p.Fam!='НЕТ'
--IM
--Проверка того что не запонено имя сопровождающего при NOVOR=0
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Im like '%[^-а-яА-Я"''. ]%'

insert #tError 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Im IS NOT NULL AND RTRIM(LTRIM(p.Im)) like '[-"'']%'
--Проверка того что не запонено имя пациента при NOVOR=1
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=1 and p.Im!='НЕТ'
--OT
--Проверка того что не запонено отчество сопровождающего при NOVOR=0
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Ot like '%[^-а-яА-Я"''. ]%'
--------проверка отчества.т.к отчество может не содержать кирилицу
insert #tError 
select c.id as rf_idCase,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Ot IS NOT NULL AND RTRIM(LTRIM(p.Ot)) like '[-"'']%'

--Проверка того что не запонено отчество пациента при NOVOR=1
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=1 and p.Ot!='НЕТ'
--Кроме того, в этом случае проверяется выполнение равенства OT=НЕТ, если равенство выполняется, 
--то проверяется наличие элемента OS_SLUCH  в соответствующей записи файла Реестра случаев. Причем  OS_SLUCH =2
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
where r.IsChild=0 and p.Ot='НЕТ' and c.IsSpecialCase<>2
/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, 
то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: 
в качестве символов могут быть использованы только буквы кириллицы, знаки: дефис, тире, двойные кавычки, апостроф и пробел. 
Причем FAM_P не может быть равным значению «НЕТ». Если NOVOR=0,  то элемент должен отсутствовать или быть пустым.
*/
insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and ISNULL(pa.Fam,'bla-bla') like '%[^-а-яА-Я"'' ]%'

-------появились пустые фамилии и фамилии начинающиеся с -'"
insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Fam IS NOT NULL AND  RTRIM(LTRIM(pa.Fam)) like '[-"'']%'

insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and UPPER(pa.Fam)='НЕТ'
/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, 
то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: 
в качестве символов могут быть использованы только буквы кириллицы, знаки: дефис, тире, двойные кавычки, апостроф и пробел. 
Причем IM_P не может быть равным значению «НЕТ». 
Если NOVOR=0,  то элемент должен отсутствовать или быть пустым.
*/
insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and ISNULL(pa.Im,'bla-bla') like '%[^-а-яА-Я"'' ]%'

insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and UPPER(pa.Im)='НЕТ'

/*
Если в соответствующей записи случая оказания Реестра случаев NOVOR<>0, то проверяется обязательное заполнение этого элемента. 
Проверяется корректность представленного значения, а именно: в качестве символов могут быть использованы только буквы кириллицы,
знаки: дефис, тире, двойные кавычки, апостроф и пробел. Кроме того, в этом случае проверяется  выполнение равенства OT_P=НЕТ, 
если равенство выполняется, то проверяется наличие элемента OS_SLUCH  в соответствующей записи файла Реестра случаев. Причем  OS_SLUCH =2
*/
insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Ot='НЕТ' and c.IsSpecialCase<>2

insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=0 

insert #tError 
select c.id, 578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_RefRegisterPatientRecordCase rp on
				r.id=rp.rf_idRecordCase
							inner join t_RegisterPatient p on
				rp.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile														
							inner join t_Case c on
				r.id=c.rf_idRecordCase	
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and ISNULL(pa.Ot,'bla-bla') like '%[^-а-яА-Я"'' ]%'
--W
--Проводится проверка соответствия представленного значения классификатору V005
insert #tError
select distinct c.id,578
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.rf_idV005<1
insert #tError
select distinct c.id,578
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.rf_idV005>2
--DR
insert #tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age<0

insert #tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age>115

insert #tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.BirthDay>=GETDATE()
--FAM_P
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Fam like '%[^-а-яА-Я"'' ]%' and pa.Fam<>'НЕТ'
--IM_P
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Im like '%[^-а-яА-Я"'' ]%' and pa.Im<>'НЕТ'

--OT_P
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Ot like '%[^-а-яА-Я"'' ]%' 
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.Ot='НЕТ' and c.IsSpecialCase<>2
--W_P
insert #tError 
select c.id,578
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.rf_idV005>2 and pa.rf_idV005<1
--DR_P
insert #tError 
select c.id,579
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientAttendant pa on
				p.id=pa.rf_idRegisterPatient
where r.IsChild=1 and pa.BirthDay>=GETDATE() and DATEDIFF(YEAR,pa.BirthDay,GETDATE())>105
--DOC_TYPE
--Если не ЕНП данное поле должно быть заполнено
insert #tError 
select c.id,580
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.rf_idF008<>3							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							left join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
where d.rf_idRegisterPatient is null
--Проверка на соответствие справочнику F011
insert #tError 
select c.id,580
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.rf_idF008<>3							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
							left join vw_sprF011 f011 on
				d.rf_idDocumentType=f011.ID
where f011.ID is null
--MR
--при скорой помощи данные документов не указываются
insert #tError 
select c.id,584
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
				and c.rf_idV006<>4
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
				and d.rf_idDocumentType=14
where p.BirthPlace is null

insert #tError 
select c.id,584
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
				and c.rf_idV006<>4
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
				and d.rf_idDocumentType=3
where p.BirthPlace is null
--SNILS
insert #tError 
select c.id,582
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.rf_idF008<>3							
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient				
				and d.SNILS is not null
where d.SNILS not like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9]' 
		and d.SNILS not like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9] [0-9][0-9]' 
		
----17.01.2014 Новые проверки
--Если поле заполнено, то проверяется возраст пациента: на дату начала лечения пациенту должно быть не более 60 дней
insert #tError 
select c.id,507
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN t_RefRegisterPatientRecordCase r1 ON
			r.id=r1.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
			r1.rf_idRegisterPatient=p.id
where r.BirthWeight IS NOT NULL AND DATEDIFF(dd,c.DateBegin,p.BirthDay)>60
--508
--Проводится проверка на соответствие справочнику V014
insert #tError 
select c.id,508
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
WHERE NOT EXISTS(SELECT * FROM OMS_NSI.dbo.sprV014 v WHERE v.IDFRMMP=c.rf_idV014)			
--511
--Если поля заполнены, то проводится проверка возраста пациента: на дату начала лечения пациент должен быть старше 1 года
insert #tError 
select c.id,511
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN t_RefRegisterPatientRecordCase r1 ON
			r.id=r1.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
			r1.rf_idRegisterPatient=p.id
						INNER JOIN dbo.t_BirthWeight w ON
			c.id=w.rf_idCase
where DATEDIFF(Year,c.DateBegin,p.BirthDay)>1
--512
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase						
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.V001 WHERE IDRB=m.MUSurgery)
--Если значение не совпадает со значением в теге CODE_USL или не соответствует номенклатуре медицинских услуг (V001)
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN OMS_NSI.dbo.V001 v ON
			m.MUSurgery=v.IDRB
WHERE m.MUSurgery IS NOT NULL AND m.MUSurgery<>m.MUCode	
--Если в качестве значения указан код из номенклатуры медицинских услуг (V001), то проверяется наличие тега VID_VME  и его значение должно быть непустым.
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN OMS_NSI.dbo.V001 v ON
			m.MUCode=v.IDRB
WHERE ISNULL(m.MUSurgery,'bla-bla')<>m.MUCode	
--509
--Проводится проверка 1: если VIDPOM=32, то поле должно быть заполнено обязательно и указанное значение должно соответствовать классификатору видов ВМП V018 
insert #tError 
select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008=32 AND c.rf_idV018 IS NULL
insert #tError 
select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase					
WHERE c.rf_idV008=32 AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.sprV018 WHERE code=c.rf_idV018) 		

insert #tError 
select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV008<>32 AND c.rf_idV018 IS NOT NULL				

insert #tError 
select c.id,509
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase					
WHERE c.rf_idV018 IS NOT NULL AND NOT EXISTS(SELECT * FROM OMS_NSI.dbo.sprV018 WHERE code=c.rf_idV018) 
--510
--Проводится проверка 1: если VIDPOM=32, то поле должно быть заполнено обязательно и указанное значение должно соответствовать классификатору методов ВМП V019 
--(поле IDHM). Если значение соответствует классификатору методов ВМП, то проводится проверка соответствия указанного метода ВМП виду ВМП 
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
insert #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase					
						INNER JOIN (SELECT DISTINCT rf_idCase,RTRIM(DiagnosisCode) AS DiagnosisCode FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d ON
			c.id=d.rf_idCase
WHERE c.rf_idV008=32 AND NOT EXISTS(SELECT * FROM dbo.vw_sprV019 WHERE IDHM=c.rf_idV019 AND IDHVID=c.rf_idV018 AND RTRIM(DiagnosisCode)=RTRIM(d.DiagnosisCode) ) 
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

insert #tError 
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase		
WHERE c.rf_idV019 IS NOT NULL AND NOT EXISTS(SELECT * FROM vw_sprV019 WHERE IDHM=c.rf_idV019)
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

begin transaction
begin try
	if(select @@SERVERNAME)!='TSERVER'
	begin
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select distinct ErrorNumber,@idFile,rf_idCase from #tError
	end
	drop table #tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()	
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
