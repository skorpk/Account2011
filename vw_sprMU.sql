USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprMUCompletedCase]    Script Date: 06/18/2013 15:43:39 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprMU]'))
DROP VIEW dbo.vw_sprMU
GO
CREATE VIEW [dbo].[vw_sprMU]
AS
SELECT DISTINCT CAST(MUGroupCode AS varchar(2)) + '.' + CAST(MUUnGroupCode AS varchar(2)) + '.' + CAST(MUCode AS varchar(3)) AS MU, AdultUET, ChildUET, 
                unitCode, unitName,MUGroupCode,MUUnGroupCode,MUCode,beginDate,endDate
FROM         (
				select m.MUId,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.AdultUET,m.ChildUET
						,unit.unitCode,unit.unitName, unit.beginDate, unit.endDate
						,cc.[Profile],cc.AgeGroupShortName,	cc.MUGroupCodeP
						,cc.MUUnGroupCodeP,cc.MUCodeP,m.MUName,m.IsCompletedCase
				from OMS_NSI.dbo.vw_sprMU m	left join (
															SELECT TOP 100 percent mu.rf_MUId,t2.unitCode,t2.UnitName, t.beginDate, t.endDate,t.Flag
															FROM OMS_NSI.dbo.tPlanUnitPeriod t INNER JOIN   OMS_NSI.dbo.tPlanUnit t2 ON
																		t.rf_PlanUnitID=t2.PlanUnitId
																					INNER JOIN oms_nsi.dbo.tMUPlanUnit mu ON
																		t2.PlanUnitId=mu.rf_PlanUnitID
															ORDER BY rf_MUId 
														) unit on
							m.MUId=unit.rf_MUId
										left join OMS_NSI.dbo.vw_sprCompletedCasePatientAge cc on
							m.MUId=cc.rf_MUId	
			)  t
GO