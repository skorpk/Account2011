USE [oms_NSI]
GO
/****** Object:  View [dbo].[vw_sprT001]    Script Date: 12/01/2011 08:20:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if OBJECT_ID('vw_sprT001',N'V') is not null
drop view vw_sprT001
go
CREATE view [dbo].[vw_sprT001]
as
select mcod,left(tfomsCode,6) as CodeM,mnameF as Namef,mnameS as NameS,INN,KPP,fam as fam_ruk,im as Im_ruk,ot as Ot_ruk,Phone,email as Mail,
		beginDate as DateBeg,endDate as DateEnd
from tMO
where isnull(mcod,'')<>'' and tfomsCode is not null
GO
/****** Object:  View [dbo].[vw_sprMU]    Script Date: 12/01/2011 08:20:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if OBJECT_ID('vw_sprMU',N'V') is not null
drop view vw_sprMU
go
create view [dbo].[vw_sprMU]
as
select m3.MUId,m1.MUGroupCode,m2.MUUnGroupCode,m3.MUCode,m3.MUName,m3.rf_PlanUnitId,m3.AdultUET,m3.ChildUET		
from dbo.sprMUGroup m1 inner join dbo.sprMUUnGroup m2 on
			m1.MUGroupId=m2.rf_MUGroupId 
						inner join dbo.sprMU m3 on
			m2.MUUnGroupId=m3.rf_MUUnGroupId
GO
/****** Object:  View [dbo].[vw_sprCompletedCasePatientAge]    Script Date: 12/01/2011 08:20:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if OBJECT_ID('vw_sprCompletedCasePatientAge',N'V') is not null
drop view vw_sprCompletedCasePatientAge
go
create view [dbo].[vw_sprCompletedCasePatientAge]
as
select cc.rf_MUId,cc.rf_MUIdPD,cc.Profile,age.AgeGroupName,age.AgeGroupShortName,
		m1.MUGroupCode as MUGroupCodeP,m1.MUUnGroupCode as MUUnGroupCodeP,m1.MUCode as MUCodeP
from dbo.sprCompletedCasePatientDay cc inner join dbo.sprAgeGroup age on
			cc.rf_AgeGroupId=age.AgeGroupId
						inner join vw_sprMU m1 on
			cc.rf_MUIdPD=m1.MUId
GO
/****** Object:  View [dbo].[vw_sprMUAll]    Script Date: 12/01/2011 08:20:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if OBJECT_ID('vw_sprMUAll',N'V') is not null
drop view vw_sprMUAll
go
create view [dbo].[vw_sprMUAll]
as
select m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.AdultUET,m.ChildUET,
		unit.unitCode,unit.unitName,cc.[Profile],cc.AgeGroupShortName,	cc.MUGroupCodeP,cc.MUUnGroupCodeP,cc.MUCodeP 
from dbo.vw_sprMU m	left join dbo.tPlanUnit unit on
			m.rf_PlanUnitId=unit.PlanUnitId
						left join vw_sprCompletedCasePatientAge cc on
			m.MUId=cc.rf_MUId
GO
