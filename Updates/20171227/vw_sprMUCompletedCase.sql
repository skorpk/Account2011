USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprMUCompletedCase]    Script Date: 27.12.2017 14:48:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter view [dbo].[vw_sprMUCompletedCase]
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P,
		MUId,DiagnosisType,MUGroupCode,MUUnGroupCode,MUCode,IsSpecialCase,MUName,calculationType
from (
		select m.MUId,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.AdultUET,m.ChildUET,
				unit.unitCode,unit.unitName,cc.[Profile],cc.AgeGroupShortName,	cc.MUGroupCodeP
				,cc.MUUnGroupCodeP,cc.MUCodeP,m.MUName,DiagnosisType,m.IsSpecialCase,calculationType
		from oms_nsi.dbo.vw_sprMU m	left join oms_nsi.dbo.tPlanUnit unit on
			m.rf_PlanUnitId=unit.PlanUnitId
						left join oms_nsi.dbo.vw_sprCompletedCasePatientAge cc on
			m.MUId=cc.rf_MUId
		where m.IsCompletedCase=1
		) t


GO


