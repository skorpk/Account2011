USE RegisterCases
GO
IF OBJECT_ID('vw_sprF08',N'V') IS NOT NULL
DROP VIEW vw_sprF08
GO
CREATE VIEW vw_sprF08
AS
SELECT ID,Name FROM oms_nsi.dbo.sprInsuranceFactDocumentType
GO
IF OBJECT_ID('vw_sprF002',N'V') IS NOT NULL
DROP VIEW vw_sprF002
GO
CREATE VIEW vw_sprF002
AS
SELECT * FROM oms_nsi.dbo.sprSMO
GO
IF OBJECT_ID('vw_sprOKATO',N'V') IS NOT NULL
DROP VIEW vw_sprOKATO
GO
CREATE VIEW vw_sprOKATO
AS
SELECT  OKATO AS OKATO,[namel],[centrum]      
FROM [oms_NSI].[dbo].[sprOKATO]  WHERE OKATO is not null--kod1='000' AND centrum IS NOT NULL 
GO
IF OBJECT_ID('vw_sprOKATOFull',N'V') IS NOT NULL
DROP VIEW vw_sprOKATOFull
GO
CREATE VIEW vw_sprOKATOFull
AS
SELECT  OKATOFull AS OKATO,[namel]
FROM [oms_NSI].[dbo].[sprOKATO] 
GO
IF OBJECT_ID('vw_sprV08',N'V') IS NOT NULL
DROP VIEW vw_sprV08
GO
CREATE VIEW vw_sprV08
AS
SELECT ID,Name FROM oms_nsi.dbo.sprV008
GO
IF OBJECT_ID('vw_sprV002',N'V') IS NOT NULL
DROP VIEW vw_sprV002
GO
CREATE VIEW vw_sprV002
AS 
SELECT id,name FROM oms_NSI.dbo.sprV002
GO
IF OBJECT_ID('vw_sprV009',N'V') IS NOT NULL
DROP VIEW vw_sprV009
GO
CREATE VIEW vw_sprV009
AS 
SELECT id,name FROM oms_NSI.dbo.sprV009
GO
IF OBJECT_ID('vw_sprV012',N'V') IS NOT NULL
DROP VIEW vw_sprV012
GO
CREATE VIEW vw_sprV012
AS 
SELECT id,name FROM oms_NSI.dbo.sprV012
GO
IF OBJECT_ID('vw_sprV004',N'V') IS NOT NULL
DROP VIEW vw_sprV004
GO
CREATE VIEW vw_sprV004
AS 
SELECT id,name FROM oms_NSI.dbo.sprMedicalSpeciality
GO
IF OBJECT_ID('vw_sprV010',N'V') IS NOT NULL
DROP VIEW vw_sprV010
GO
CREATE VIEW vw_sprV010
AS 
SELECT id,name FROM oms_NSI.dbo.sprV010
GO
IF OBJECT_ID('vw_sprPriceLevelMO',N'V') IS NOT NULL
DROP VIEW vw_sprPriceLevelMO
GO
CREATE VIEW [dbo].[vw_sprPriceLevelMO]
AS
SELECT p.MSPricePeriodId
	  ,t.CodeM
	  ,c.code AS rf_idV006
	  ,l.MSLevelId AS LevelPayType
	  ,p.beginDate AS DateBegin
	  ,p.endDate AS DateEnd
FROM oms_NSI.dbo.tMSPricePeriod p INNER JOIN oms_NSI.dbo.tMSCondition c ON 
			p.rf_MSConditionId = c.MSConditionId 
								INNER JOIN oms_NSI.dbo.tMSLevel l ON 
			p.rf_MSLevelId = l.MSLevelId
								inner join oms_NSI.dbo.vw_sprT001 t on
			p.rf_MOId=t.MOId
go
IF OBJECT_ID('vw_sprMUCompletedCaseDiagnosis',N'V') IS NOT NULL
DROP VIEW vw_sprMUCompletedCaseDiagnosis
GO
CREATE VIEW [dbo].[vw_sprMUCompletedCaseDiagnosis]
AS
select distinct m.MU
	  ,d.DiagnosisCode,case when mu.rf_DiagnosisTypeId=2 then 1 else 3 end as DiagnosisType
from oms_NSI.dbo.sprCompletedCaseDiagnosis d inner join vw_sprMUCompletedCase m on
				d.rf_MUId=m.MUId
				and d.flag='A'
							inner join oms_nsi.dbo.sprMU mu on
				m.MUId=mu.MUId
--where m.unitCode is not null
GO
IF OBJECT_ID('vw_sprMKB10InOMS',N'V') IS NOT NULL
DROP VIEW vw_sprMKB10InOMS
GO
CREATE VIEW dbo.vw_sprMKB10InOMS
AS
select DiagnosisCode,DateBeg,DateEnd from oms_NSI.dbo.sprMKBInOMS
go
IF OBJECT_ID('vw_sprCompletedCaseMUDate',N'V') IS NOT NULL
DROP VIEW vw_sprCompletedCaseMUDate
GO
CREATE VIEW dbo.vw_sprCompletedCaseMUDate
AS
select distinct l.CodeM,m.MU,vm.beginDate as DateBeg, vm.endDate as DateEnd
from vw_sprMUCompletedCase m inner join oms_NSI.dbo.tValidMU vm on
			m.MUId=vm.rf_MUId
			and vm.flag='A'
							inner join oms_NSI.dbo.vw_sprT001 l on
			vm.rf_MOId=l.MOId
GO
IF OBJECT_ID('vw_sprCompletedCaseMUTariff',N'V') IS NOT NULL
DROP VIEW vw_sprCompletedCaseMUTariff
GO
CREATE VIEW dbo.vw_sprCompletedCaseMUTariff
AS
select m.MU,case when mp.rf_AgeGroupId=1 then 0 else 1 end IsChild
	  ,mp.MUPriceDateBeg,mp.MUPriceDateEnd,mp.Price
	  ,mp.rf_MSLevelId as LevelType
	  ,l.CodeM
from oms_NSI.dbo.sprMUPrice mp inner join vw_sprMUCompletedCase m on
				mp.rf_MUId=m.MUId
				and mp.flag='A'
								left join oms_NSI.dbo.vw_sprT001 l on
				mp.rf_MOId=l.MOId
GO
IF OBJECT_ID('vw_sprV006',N'V') IS NOT NULL
DROP VIEW vw_sprV006
GO
CREATE VIEW dbo.vw_sprV006
AS
select id, name,DateBeg,isnull(DateEnd,'22220101') as DateEnd from oms_NSI.dbo.sprV006
go
IF OBJECT_ID('vw_sprMUNotCompletedCase',N'V') IS NOT NULL
DROP VIEW vw_sprMUNotCompletedCase
GO
CREATE VIEW dbo.vw_sprMUNotCompletedCase
AS
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P,
		MUId
from oms_NSI.dbo.vw_sprMUAll
where MUGroupCodeP is null
go
IF OBJECT_ID('vw_sprNotCompletedCaseMUTariff',N'V') IS NOT NULL
DROP VIEW vw_sprNotCompletedCaseMUTariff
GO
CREATE VIEW dbo.vw_sprNotCompletedCaseMUTariff
AS
select m.MU,case when mp.rf_AgeGroupId=1 then 0 else 1 end IsChild
	  ,mp.MUPriceDateBeg,mp.MUPriceDateEnd,mp.Price
	  ,mp.rf_MSLevelId as LevelType
	  ,l.CodeM
from oms_NSI.dbo.sprMUPrice mp inner join vw_sprMUNotCompletedCase m on
				mp.rf_MUId=m.MUId
				and mp.flag='A'
								left join oms_NSI.dbo.vw_sprT001 l on
				mp.rf_MOId=l.MOId
GO
IF OBJECT_ID('vw_sprNotCompletedCaseMUDate',N'V') IS NOT NULL
DROP VIEW vw_sprNotCompletedCaseMUDate
GO
CREATE VIEW dbo.vw_sprNotCompletedCaseMUDate
AS
select distinct l.CodeM,m.MU,vm.beginDate as DateBeg, vm.endDate as DateEnd
from vw_sprMUNotCompletedCase m inner join oms_NSI.dbo.tValidMU vm on
			m.MUId=vm.rf_MUId
			and vm.flag='A'
							inner join oms_NSI.dbo.vw_sprT001 l on
			vm.rf_MOId=l.MOId
GO
IF OBJECT_ID('vw_sprF011',N'V') IS NOT NULL
DROP VIEW vw_sprF011
GO
CREATE VIEW dbo.vw_sprF011
AS
select ID,Name,Seria,Number from oms_NSI.dbo.sprDocumentType
go
ALTER view [dbo].[vw_sprMUCompletedCase]
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P,
		MUId,DiagnosisType
from (select m.MUId,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.AdultUET,m.ChildUET,
		unit.unitCode,unit.unitName,cc.[Profile],cc.AgeGroupShortName,	cc.MUGroupCodeP
		,cc.MUUnGroupCodeP,cc.MUCodeP,m.MUName,DiagnosisType
		from oms_nsi.dbo.vw_sprMU m	left join oms_nsi.dbo.tPlanUnit unit on
			m.rf_PlanUnitId=unit.PlanUnitId
						left join oms_nsi.dbo.vw_sprCompletedCasePatientAge cc on
			m.MUId=cc.rf_MUId) t
where MUGroupCodeP is not null
GO
IF OBJECT_ID('vw_sprLPUInOMS',N'V') IS NOT NULL
DROP VIEW vw_sprLPUInOMS
GO
CREATE VIEW dbo.vw_sprLPUInOMS
AS
select left(tfomsCode,6) as CodeM,beginDate as DateBegin,endDate as DateEnd from oms_NSI.dbo.V_PeriodInOMS
GO
---------------------------CREATE TABLE IN RegisterCases-------------------------------------------------------
if OBJECT_ID('sprLPUEnableCalendar',N'U') is not null
drop table sprLPUEnableCalendar
go
create table sprLPUEnableCalendar
(
	CodeM varchar(6),--код МО
	typePR_NOV bit-- 1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
)
go
---------------------------CREATE INDEXES------------------------------------------
CREATE NONCLUSTERED INDEX IX_GUID_ID
ON [dbo].[t_Case] ([GUID_Case])
INCLUDE ([id])
GO
CREATE NONCLUSTERED INDEX [IX_RecordCase_RefRegistersCase] ON [dbo].[t_RecordCase] 
( 
	[rf_idRegistersCase] ASC
)
INCLUDE ( [id],[ID_Patient],[NumberPolis],[rf_idF008],[NewBorn],idRecord,IsNew) 
WITH (DROP_EXISTING = ON, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_MES_Tariff
ON [dbo].[t_MES] ([Tariff])
INCLUDE ([rf_idCase])
GO
CREATE NONCLUSTERED INDEX [IX_Meduslugi_idCase_GUIDMU] ON [dbo].[t_Meduslugi] 
(
	[rf_idCase] ASC,[GUID_MU] ASC,[id] ASC
)
INCLUDE(rf_idMO) WITH (DROP_EXISTING = ON, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_Case_idRecordCase_ID] ON [dbo].[t_Case] 
(
	[rf_idRecordCase] ASC
)
INCLUDE ( [id],[GUID_Case],[idRecordCase],[DateBegin],[DateEnd],[AmountPayment],[Age],[IsChildTariff],rf_idDirectMO,rf_idV006,rf_idV002
		,NumberHistoryCase,IsSpecialCase,rf_idV008,rf_idMO,rf_idV004,rf_idV010) 
WITH (DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
CREATE NONCLUSTERED INDEX [IX_PatientSMO_idRecordCase] ON [dbo].[t_PatientSMO] 
(
	[ref_idRecordCase] ASC
)
INCLUDE ( [rf_idSMO],[OKATO],Name) WITH (DROP_EXISTING = ON, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Meduslugi_Case] ON [dbo].[t_Meduslugi] 
(
	[rf_idCase] ASC
)
INCLUDE ( [DateHelpBegin],[DateHelpEnd],[IsChildTariff],[MUCode],[Quantity],[Price],rf_idV002,TotalPrice)
WITH (DROP_EXISTING = ON, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [RegisterCases]
GO
IF OBJECT_ID('usp_IsCODEExists', N'P') IS NOT NULL
	DROP PROC usp_IsCODEExists
GO
CREATE PROCEDURE usp_IsCODEExists
				@code int,
				@codeM char(6)
as
select COUNT(*) 
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
where CodeM=@codeM and a.idRecord=@code
go
-------------------------------------------usp_RunFirstProcessControl-----------------
--не запускать пока не пройдена стадия тестирования	
alter proc usp_RunFirstProcessControl
			@idFile int			
as
set nocount on

declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

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
-----------------------------------------------------------------------Cases----------------------------------------------------
--дубликаты по IDSERV
insert @tError
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

	

------------------------------------------------------------------------------
--QUERY 2

--Новый проверки точнее с новыми кодами ошибок
--03.10.2012
--N_ZAP
insert @tError 
select c.id,530
from (select ROW_NUMBER() OVER(order by r.idRecord asc) as idNumber,r.id,r.idRecord
	  from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
		) r	inner join t_Case c on
		r.id=c.rf_idRecordCase
where r.idNumber<>r.idRecord

--PR_NOV
insert @tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile and r.IsNew>1

insert @tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Case c1 on
			c.GUID_Case=c1.GUID_Case
			and c.id<>c1.id	
where a.rf_idFiles=@idFile and r.IsNew=0

insert @tError
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
insert @tError
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
insert @tError
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
insert @tError
select c.id,534
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.rf_idF008=2 and r.NPolisLen!=9

insert @tError 
select c.id,534
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.rf_idF008=3 and r.NPolisLen!=16
--SMO
insert @tError
select distinct c.id,535
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprF002 f on
			s.rf_idSMO=f.SMOKOD
where f.SMOKOD is null
insert @tError
select distinct c.id,535
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
			and s.rf_idSMO='18000'
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprSMO f on
			s.rf_idSMO=f.smocod
where f.smocod is null
--SMO_OK
insert @tError
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
where f.OKATO is null
--SMO_NAM
insert @tError
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
insert @tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and LEN(r.NewBorn)<>9

--если не новорожденный то кроме
insert @tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=0 and r.NewBorn<>'0'		
---проверка пола
insert @tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and left(r.NewBorn,1) not in ('1','2')

--Проверка 12: если NOVOR=0 то недолжно быть записей в t_RegisterPatientAttendant
insert @tError 
select t.rf_idCase,538
from (
	  select c.id as rf_idCase, p.id as ID_Patient
	  from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join vw_RegisterPatient p on
				r.id=p.rf_idRecordCase
							inner join t_Case c on
				r.id=c.rf_idRecordCase								
	  where r.IsChild=0 
	  ) t inner join t_RegisterPatientAttendant pa on
		t.ID_Patient=pa.rf_idRegisterPatient
--возраст пациента на дату начала лечения должен быть не меньше 0 и не больше 3 (возраст рассчитывается как количество полных лет между значением в поле DR(дата рождения) и DATE_1(дата начала лечения))
insert @tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.Age<0 and c.Age>3
--значение в теге DET как на уровне случая, так и на уровне медуслуг (если присутствуют) должно быть равно 1
insert @tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where r.IsChild=1 and c.IsChildTariff=0

insert @tError 
select c.id,538
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
where r.IsChild=1 and m.IsChildTariff=0
--IDCASE
--Для первой записи файла Реестра случаев значение в этом поле должно быть равно 1, последующие значения должны быть результатом сложения предыдущего значения и 1
insert @tError 
select c.id,539
from (select ROW_NUMBER() OVER(order by c.idRecordCase asc) as idNumber,c.id,c.idRecordCase
	  from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
		) c	
where c.idNumber<>c.idRecordCase
--ID_C
--дубликаты по ID_C
insert @tError
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
insert @tError
select distinct c.id,542
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
insert @tError
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

insert @tError
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
						
--VIDPOM
insert @tError
select distinct c.id,542
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV08 f on
			c.rf_idV008=f.ID
where f.ID is null
--NPR_MO
insert @tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprT001 l on
			c.rf_idDirectMO=l.mcod
where c.rf_idDirectMO is not null and l.CodeM is null
--поле должно быть заполнено обязательно, при условии USL_OK=1  и EXTR=1 
insert @tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.HopitalisationType=1 and c.rf_idV006=1 and c.rf_idDirectMO is null
--поле должно быть заполнено обязательно, если в теге USL присутствует услуга с кодом  60.2.1 или 60.2.2 (компьютерная томография)
insert @tError
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
insert @tError
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
--EXTR
insert @tError
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
insert @tError
select distinct c.id,544
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
where c.HopitalisationType is null and c.rf_idV006=1
--LPU
--соответствия кода медицинской организации реестровому номеру медицинской организации, указанному в теге CODE_MO,
insert @tError
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
insert @tError
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
insert @tError
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
--DET
insert @tError
select distinct c.id,547
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age>17 and c.IsChildTariff=1

insert @tError
select distinct c.id,547
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age<18 and c.IsChildTariff=0

insert @tError
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
insert @tError
select distinct c.id,548
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
where a.rf_idFiles=@idFile and len(ltrim(c.NumberHistoryCase))<1
--DATE_1
--дата начала лечения должна принадлежать текущему или предыдущему году
insert @tError
select c.id,549
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
where c.DateBegin>c.DateEnd
--DATE_2
--дата окончания лечения должна принадлежать отчетному периоду, указанному в реквизитах счета 
insert @tError
select c.id,55
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
where c.DateEnd<@dateStart or c.DateEnd>=@dateEnd

insert @tError
select c.id,550
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
where c.DateEnd>a.DateRegister
--проверяется участие медицинской организации в системе ОМС в течение всего срока лечения
insert @tError
select c.id,551
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase
						inner join vw_sprLPUInOMS oms on
					c.rf_idMO=oms.CodeM
					and c.DateBegin>oms.DateBegin
					and c.DateEnd<oms.DateEnd
where oms.CodeM is null

--------------------------------------------------------------------------------------------------------------------------------
--проверяем для данного МО включать эту проверку или нет.
--Если typePR_NOV=0 то проверка для новых случаев, если typePR_NOV=1 то проверка для исправленных случаев
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
--Это если запись подается впервые
	insert @tError
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
	insert @tError
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
declare @dateAdd tinyint
--вычисляем кол-во дней на исправление неправильных записей
select @dateAdd=spr.ControlDateDay
from t_RegistersCase a inner join sprCalendarPR_NOV1 spr on
		a.ReportYear=spr.ReportYear
		
	insert @tError
	select c1.id,50
	from(
		select c.id,DATEADD(DAY,@dateAdd,MAX(fb.DateCreate)) as DateRegSPTK
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
				and rb.TypePay=2
								inner join t_RegisterCaseBack ab on
				rb.rf_idRegisterCaseBack=ab.id
								inner join t_FileBack fb on
				ab.rf_idFilesBack=ab.id
								left join t_ErrorProcessControl e on
				c1.id=e.rf_idCase
				and e.ErrorNumber=57
		where e.rf_idCase is null
		group by c.id
		 ) c1 
	where GETDATE()>=c1.DateRegSPTK
end

--DS01
--Сверка на справочник. Не реализованна проверка на сроки
insert @tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join vw_Diagnosis d on
					c.id=d.rf_idCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS1=(mkb.DiagnosisCode)
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null
--на соответствие диагноза из ОМС
insert @tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join vw_Diagnosis d on
					c.id=d.rf_idCase
								left join vw_sprMKB10InOMS mkb on
					d.DS1=(mkb.DiagnosisCode)
					and c.DateEnd>=mkb.DateBeg
					and c.DateEnd<=mkb.DateEnd
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null

--DS0 DS2
insert @tError
select t.id,t.Error
from (
		select distinct c.id,552 as Error
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join vw_Diagnosis d on
					c.id=d.rf_idCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS0=mkb.DiagnosisCode
		where a.rf_idFiles=@idFile and d.DS0 is not null and mkb.DiagnosisCode is null
		union all
		select distinct c.id,552
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join vw_Diagnosis d on
					c.id=d.rf_idCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS2=mkb.DiagnosisCode
		where a.rf_idFiles=@idFile and d.DS2 is not null and mkb.DiagnosisCode is null
	 ) t
	 
--CODE_MES1
--Проверка 4: проверка того что в таблице МЕС лежат только коды законченных случаев
insert @tError
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
	  ) t left join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
where t1.MU is null
--2.	соответствия кода основного (сопутствующего) диагноза кодам диагнозов
--соответствие CODE_MES1+DS1 и CODE_MES1+DS2
/*
insert @tError
select distinct rf_idCase,555
from (
		select mes.rf_idCase,mes.MES as MUCode,case when mu.DiagnosisType=1 then d.DS1 else d.DS2 end as DS,mu.DiagnosisType
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
							inner join t_Case c on
						r.id=c.rf_idRecordCase	
							inner join t_MES mes on
						c.id=mes.rf_idCase
							inner join vw_Diagnosis d on
						c.id=d.rf_idCase	
							inner join vw_sprMUCompletedCase mu on
						mes.MES=mu.MU							
	  ) t left join dbo.vw_sprMUCompletedCaseDiagnosis t1 on
			rtrim(t.MUCode)=t1.MU
			and t.DiagnosisType=t1.DiagnosisType
			and isnull(t.DS,'bla-bla')=rtrim(t1.DiagnosisCode)
where t1.DiagnosisCode is null
*/
			
--Проверка 5: что в таблице медуслуг нету кодов законченых случаев
insert @tError
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
	  ) t inner join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU

--4.	по дате окончания лечения проводится проверка на правомочность применения медицинской организацией указанного кода законченного случая. Проверка проводится в соответствии со справочником разрешенных к применению медицинских услуг
insert @tError
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join dbo.vw_sprCompletedCaseMUDate t1 on
			mes.MES=t1.MU
			and c.DateEnd>=t1.DateBeg
			and c.DateEnd<=t1.DateEnd
where t1.MU is null
--RSLT
insert @tError
select distinct c.id,559
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV009 v on
			c.rf_idV009=v.id
where v.id is null

--ISHOD
insert @tError
select distinct c.id,560
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV012 v on
			c.rf_idV012=v.id
where v.id is null
--PRVS
insert @tError
select distinct c.id,561
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV004 v on
			c.rf_idV004=v.id
where v.id is null
--OS_SLUCH
--проводится проверка на соответствие допустимому значению 2
insert @tError 
select c.id, 563
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
							inner join t_Case c on
				r.id=c.rf_idRecordCase								
where r.IsChild=0 and c.IsSpecialCase<>2
--если NOVOR=0, то проводится проверка на указание в поле OT значения “НЕТ” в Реестре пациентов (без учета регистра)
insert @tError 
select c.id, 563
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
where r.IsChild=0 and c.IsSpecialCase=2 and p.Ot is not null	  
--если NOVOR <> 0, то проводится проверка на указание в поле OT_P значения «НЕТ» в Реестре пациентов (без учета регистра)
insert @tError 
select c.id, 563
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
where r.IsChild=1 and c.IsSpecialCase=2 and pa.Ot is not null	  
--IDSP
insert @tError
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
insert @tError
select mes.rf_idCase,565
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Quantity<>1		
--TARIF
insert @tError
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
insert @tError
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
insert @tError
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
				and c.DateEnd>=t1.DateBegin
				and c.DateEnd<=t1.DateEnd
where t1.CodeM is null
-------------------------------------------------------для общих тариффов
insert @tError
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
								inner join vw_sprMUCompletedCase m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType<>4
		) t left join vw_sprCompletedCaseMUTariff mp on
				t.MES=mp.MU
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null
-------------------------------------------------------для индивидуальных тарифов
insert @tError
select t.id,65
from (
		select c.id,mes.MES,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Tariff,c.rf_idMO
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
								inner join t_MES mes on
						c.id=mes.rf_idCase
								inner join vw_sprMUCompletedCase m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						and c.rf_idV006=t1.rf_idV006
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4
		) t left join vw_sprCompletedCaseMUTariff mp on
				t.MES=mp.MU
				and t.rf_idMO=mp.CodeM
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Tariff=mp.Price
where mp.MU is null
				
--SUMV
--если применен способ оплаты по законченному случаю,  то SUMV=TARIF и должна быть больше 0
insert @tError
select mes.rf_idCase,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase
where mes.Tariff<>c.AmountPayment

insert @tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.AmountPayment<=0
--если применен способ оплаты, отличный от способа оплаты по законченному случаю, то значение должно быть равно сумме стоимостей всех услуг
--(стоимость услуг равна произведению количества услуг на тариф одной услуги) и должна быть больше 0
insert @tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join vw_MeduslugiMes m on
			c.id=m.rf_idCase
where a.rf_idFiles=@idFile
group by c.id,c.AmountPayment
having c.AmountPayment<>cast(SUM(m.Quantity*m.Price) as decimal(15,2)) 
-----------------------------------------------------------------USL--------------------------------------------------------------
--IDSERV
--Все услуги в реестре сведений должны быть пронумерованы от 1 и далее по возрастанию 
--Отключить т.к. на этапе ФЛК могут быть откинуто часть случаев.
/*
insert @tError 
select distinct c.id,567
from (select ROW_NUMBER() OVER(order by m.id asc) as idNumber,c.id,m.id as idRecord
	  from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
		) c	
where c.idNumber<>c.idRecord
*/
--ID_U
--дубликаты по ID_U
insert @tError
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
insert @tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.rf_idMO<>m.rf_idMO
--PROFIL
insert @tError
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

insert @tError
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
where c.rf_idV002<>m.rf_idV002	

--DATE_IN
--Проверка 2: на дату начала услуги
insert @tError
select distinct c.id,572
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase 
where c.DateBegin>m.DateHelpBegin
--DATE_OUT
--Проверка 2: на дату окончания услуги
insert @tError
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
		where m.DateHelpBegin>m.DateHelpEnd or m.DateHelpEnd>c.DateEnd
		union all
		select c.id
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
								inner join t_Case c on
							r.id=c.rf_idRecordCase	
								inner join t_Meduslugi m on
					c.id=m.rf_idCase 
		where m.DateHelpEnd>c.DateEnd
	) c
--DS
insert @tError
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
--CODE_USL
--если код медицинской услуги  не соответствует кодам из Справочника медицинских услуг и их тарифов с учетом профиля, условий оказания, 
--специальности врача, способа оплаты.
insert @tError
select distinct c.id,554
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase	
						left join (
									select MU from vw_sprMUNotCompletedCase
									union select IDRB from oms_NSI.dbo.V001
									) vm on
			m.MUCode=vm.MU						
where vm.MU is null


--	если на  дату окончания лечения медицинская услуга не разрешена к применению данному медицинскому учреждению
insert @tError
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase
						inner join vw_sprMU mu on
				mes.MUCode=mu.MU
						left join dbo.vw_sprNotCompletedCaseMUDate t1 on
			mes.MUCode=t1.MU
			and c.DateEnd>=t1.DateBeg
			and c.DateEnd<=t1.DateEnd
where t1.MU is null
--KOL_USL
insert @tError
select distinct c.id,575
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where m.Quantity<=0

insert @tError
select distinct c.id,575
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where Quantity-ROUND(Quantity,0)>0
--TARIF
--Если в качестве услуги представлена хирургическая операция (класс А16 из Номенклатуры медицинских услуг), то тариф должен быть равен 0
insert @tError
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
insert @tError
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
				and c.DateEnd>=t1.DateBegin
				and c.DateEnd<=t1.DateEnd
where t1.CodeM is null
--В Справочнике медицинских услуг и тарифов для данного медицинского учреждения (если уровень оплаты - индивидуальный), 
--кода медицинской услуги, возраста пациента, уровня оплаты осуществляется поиск действующего на дату окончания лечения тарифа и 
--производится сравнение с представленным значением
-------------------------------------------------------для общих тариффов
insert @tError
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
								left join t_MES m1 on
						mes.rf_idCase=m1.rf_idCase
		where m1.rf_idCase is null
		) t left join vw_sprNotCompletedCaseMUTariff mp on
				t.MUCode=mp.MU
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Price=mp.Price
where mp.MU is null
-------------------------------------------------------для индивидуальных тарифов
insert @tError
select t.id,65
from (
		select c.id,mes.MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price,c.rf_idMO
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
								left join t_MES m1 on
						mes.rf_idCase=m1.rf_idCase
		where m1.rf_idCase is null
		) t left join vw_sprNotCompletedCaseMUTariff mp on
				t.MUCode=mp.MU
				and t.rf_idMO=mp.CodeM
				and t.LevelPayType=mp.LevelType
				and t.IsChildTariff=mp.IsChild
				and t.DateEnd>=mp.MUPriceDateBeg
				and t.DateEnd<=mp.MUPriceDateEnd
				and t.Price=mp.Price
where mp.MU is null

--SUMV_USL
insert @tError
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
insert @tError
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
			c.rf_idV004=v.id
where v.id is null

insert @tError
select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						inner join vw_sprMU mu on
			m.MUCode=mu.MU
where c.rf_idV004<>m.rf_idV004
--------------------------------------------------------------------------------Проверка данных из файла с людьми-------------------------------------------------
--ID_PAC

--поиск дубликатов по ID_PAC в файле с людьми
insert @tError
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
insert @tError
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
insert @tError 
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

insert @tError 
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
where r.IsChild=0 and p.Fam like '%[^-а-яА-Я"'' ]%'
--Проверка того что не запонено фамилия пациента при NOVOR=1
insert @tError 
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
where r.IsChild=1 and p.Fam='НЕТ'
--IM
--Проверка того что не запонено имя сопровождающего при NOVOR=0
insert @tError 
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
where r.IsChild=0 and p.Im like '%[^-а-яА-Я"'' ]%'
--Проверка того что не запонено имя пациента при NOVOR=1
insert @tError 
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
where r.IsChild=1 and p.Im='НЕТ'
--OT
--Проверка того что не запонено отчество сопровождающего при NOVOR=0
insert @tError 
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
where r.IsChild=0 and p.Ot like '%[^-а-яА-Я"'' ]%'
--Проверка того что не запонено отчество пациента при NOVOR=1
insert @tError 
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
where r.IsChild=1 and p.Ot='НЕТ'
--Кроме того, в этом случае проверяется выполнение равенства OT=НЕТ, если равенство выполняется, 
--то проверяется наличие элемента OS_SLUCH  в соответствующей записи файла Реестра случаев. Причем  OS_SLUCH =2
insert @tError 
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
--W
--Проводится проверка соответствия представленного значения классификатору V005
insert @tError
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
insert @tError
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
insert @tError
select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age<0 and c.Age>105

insert @tError
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
insert @tError 
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
insert @tError 
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
insert @tError 
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
insert @tError 
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
insert @tError 
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
insert @tError 
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
insert @tError 
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
insert @tError 
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
insert @tError 
select c.id,584
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
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
				and d.rf_idDocumentType=14
where p.BirthPlace is null

insert @tError 
select c.id,584
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
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
				and d.rf_idDocumentType=3
where p.BirthPlace is null
--SNILS
insert @tError 
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
--OKATOG	
insert @tError 	
select c.id,583
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
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient	
				and d.OKATO is not null
							left join vw_sprOKATOFull o on
				d.OKATO=o.OKATO
where o.OKATO is null
--OKATOP
insert @tError 
select c.id,583
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
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient	
				and d.OKATO_Place is not null
							left join vw_sprOKATOFull o on
				d.OKATO_Place=o.OKATO
where o.OKATO is null				

begin transaction
begin try
	insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	select distinct ErrorNumber,@idFile,rf_idCase from @tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
GO
---------------------------------------------------------------------
IF OBJECT_ID('usp_InsertLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_InsertLPUEnableCalendar
GO
CREATE PROCEDURE usp_InsertLPUEnableCalendar
				@codeM CHAR(6),
				@type BIT,--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
				@typeOperation CHAR(1) -- вид операции I - вставить, D - удалить
AS
IF NOT EXISTS(SELECT * FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type AND @typeOperation='I')
BEGIN
	INSERT sprLPUEnableCalendar(CodeM,typePR_NOV) VALUES(@codeM,@type)
END
IF EXISTS(SELECT * FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type AND @typeOperation='D')
BEGIN 
	DELETE FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type 
END
GO
--вставка данных
IF OBJECT_ID('usp_InsertAllLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_InsertAllLPUEnableCalendar
GO
CREATE PROCEDURE usp_InsertAllLPUEnableCalendar
				@type BIT--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
AS
INSERT sprLPUEnableCalendar(CodeM,typePR_NOV)
select l.CodeM,@type
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM 
		and c.typePR_NOV=@type
where c.CodeM is null
GO
--удаляем все записи.
IF OBJECT_ID('usp_DeleteAllLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_DeleteAllLPUEnableCalendar
GO
CREATE PROCEDURE usp_DeleteAllLPUEnableCalendar
				@type BIT--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
AS
delete from sprLPUEnableCalendar where typePR_NOV=@type
GO
---------------------------------------------VIEWS------------------------------------ы
--отображает список МО для которых проверка включена при первой подаче случая
IF OBJECT_ID('vw_LPUEnableCalendarPR_NOV0', N'V') IS NOT NULL
	DROP VIEW vw_LPUEnableCalendarPR_NOV0
GO
CREATE VIEW vw_LPUEnableCalendarPR_NOV0
AS
SELECT l.CodeM,l.NameS,CASE WHEN c.CodeM IS NULL THEN 'Нет' ELSE 'Да' END AS IsEnable
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM
		and c.typePR_NOV=0
GO
--отображает список МО для которых проверка включена при повторной подаче случая
IF OBJECT_ID('vw_LPUEnableCalendarPR_NOV1', N'V') IS NOT NULL
	DROP VIEW vw_LPUEnableCalendarPR_NOV1
GO
CREATE VIEW vw_LPUEnableCalendarPR_NOV1
AS
SELECT l.CodeM,l.NameS,CASE WHEN c.CodeM IS NULL THEN 'Нет' ELSE 'Да' END AS IsEnable
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM
		and c.typePR_NOV=1
GO