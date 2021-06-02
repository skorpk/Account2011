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
SELECT id,name,DL_USLOV as USL_OK FROM oms_NSI.dbo.sprV009
GO
IF OBJECT_ID('vw_sprV012',N'V') IS NOT NULL
DROP VIEW vw_sprV012
GO
CREATE VIEW vw_sprV012
AS 
SELECT id,name,DL_USLOV as USL_OK FROM oms_NSI.dbo.sprV012
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
USE RegisterCases
go
if OBJECT_ID('sprLPUEnableCalendar',N'U') is not null
drop table sprLPUEnableCalendar
go
create table sprLPUEnableCalendar
(
	CodeM varchar(6),--код МО
	typePR_NOV bit-- 1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
)
go
---------------------------ALTER SOME TABLES AND ADD INDEXES IN OMS_NSI---------------------------------------
---обновил на сервере srvsql1-st2
/*
use oms_nsi
go
alter table sprOKATO add OKATOFull varchar(11) 
go
update sprOKATO set OKATOFull=[ter]+[kod1]+kod2+kod3
go
alter table sprOKATO add OKATO char(5) 
go
update sprOKATO set OKATO=[ter]+[kod1] WHERE kod1='000' and ter!='00'-- AND centrum IS NOT NULL 
update sprOKATO set OKATO=[ter]+[kod1] WHERE kod1='100' and ter='71'
update sprOKATO set OKATO=ter+kod1 where ter='71' and kod1='140'
go
create nonclustered index IX_OKATOFull on dbo.sprOKATO(OKATOFull)
create nonclustered index IX_OKATO on dbo.sprOKATO(OKATO)
*/
---------------------------CREATE INDEXES------------------------------------------
USE [RegisterCases]
GO
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