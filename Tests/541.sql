USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=117 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

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

select distinct c.id,541, m.MUCode ,c.rf_idV006
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
where con.MUCode is NULL AND c.GUID_Case='88BFE698-A992-37A7-E053-02057DC14840'	

SELECT * 
FROM OMS_NSI.dbo.V_MUCondition WHERE MUCode='2078.0'


select c.id,594,m.Comments
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

SELECT DISTINCT CAST(MUGroupCode AS varchar(2)) + '.' + CAST(MUUnGroupCode AS varchar(2)) + '.' + CAST(MUCode AS varchar(3)) AS MU, AdultUET, ChildUET, 
                unitCode, unitName,MUGroupCode,MUUnGroupCode,MUCode,beginDate,endDate,t.MUName
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
WHERE t.MUGroupCode=7 AND t.MUUnGroupCode=61 AND t.MUCode=3