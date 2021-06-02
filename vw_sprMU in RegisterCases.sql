USE RegisterCases
GO
SELECT * FROM dbo.vw_sprMU
GO
ALTER VIEW [dbo].[vw_sprMU]
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