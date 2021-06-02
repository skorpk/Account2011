USE RegisterCases
GO
ALTER VIEW [dbo].[vw_sprMUNotCompletedCase]
AS
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P,
		MUId,MUGroupCode,MUUnGroupCode,MUCode,IsSpecialCase
		, CASE WHEN MUGroupCode=2 AND MUUnGroupCode=82 THEN 1 ELSE 0 END IsAmbulanceEmergencyRoom
from (select m.MUId,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.AdultUET,m.ChildUET,
			unit.unitCode,unit.unitName,cc.[Profile],cc.AgeGroupShortName,	cc.MUGroupCodeP
			,cc.MUUnGroupCodeP,cc.MUCodeP,m.MUName,m.IsCompletedCase,m.IsSpecialCase
	  from oms_nsi.dbo.vw_sprMU m	left join oms_nsi.dbo.tPlanUnit unit on
					m.rf_PlanUnitId=unit.PlanUnitId
									left join oms_nsi.dbo.vw_sprCompletedCasePatientAge cc on
					m.MUId=cc.rf_MUId
			) t
where t.IsCompletedCase=0
GO