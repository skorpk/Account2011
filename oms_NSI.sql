use oms_NSI
go
if OBJECT_ID('vw_sprMU',N'V') is not null
	drop view vw_sprMU
go
create view vw_sprMU
as
select m3.MUId,m1.MUGroupCode,m2.MUUnGroupCode,m3.MUCode,m3.MUName,m3.rf_PlanUnitId,m3.AdultUET,m3.ChildUET		
from dbo.sprMUGroup m1 inner join dbo.sprMUUnGroup m2 on
			m1.MUGroupId=m2.rf_MUGroupId 
						inner join dbo.sprMU m3 on
			m2.MUUnGroupId=m3.rf_MUUnGroupId
go
if OBJECT_ID('vw_sprMUAll',N'V') is not null
	drop view vw_sprMUAll
go
create view vw_sprMUAll
as
select m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.AdultUET,m.ChildUET,
		unit.unitCode,unit.unitName,cc.[Profile],cc.AgeGroupShortName,	cc.MUGroupCodeP,cc.MUUnGroupCodeP,cc.MUCodeP 
from dbo.vw_sprMU m	left join dbo.tPlanUnit unit on
			m.rf_PlanUnitId=unit.PlanUnitId
						left join vw_sprCompletedCasePatientAge cc on
			m.MUId=cc.rf_MUId												
go						
if OBJECT_ID('vw_sprCompletedCasePatientAge',N'V') is not null
	drop view vw_sprCompletedCasePatientAge
go
create view vw_sprCompletedCasePatientAge
as
select cc.rf_MUId,cc.rf_MUIdPD,cc.Profile,age.AgeGroupName,age.AgeGroupShortName,
		m1.MUGroupCode as MUGroupCodeP,m1.MUUnGroupCode as MUUnGroupCodeP,m1.MUCode as MUCodeP
from dbo.sprCompletedCasePatientDay cc inner join dbo.sprAgeGroup age on
			cc.rf_AgeGroupId=age.AgeGroupId
						inner join vw_sprMU m1 on
			cc.rf_MUIdPD=m1.MUId