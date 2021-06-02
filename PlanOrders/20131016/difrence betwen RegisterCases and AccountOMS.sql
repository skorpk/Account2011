USE RegisterCases
GO 
DECLARE @codeLPU CHAR(6)='141022'

declare @p as table(id int)
insert @p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=7 AND r.ReportMonth<=9 AND
			r.ReportYear=2013
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	

select t.rf_idMO,t.GUID_Case,t.unitCode,SUM(t.Quantity) AS Quantity
INTO #tmp_PlanOrder_Case
from (
		select c.rf_idMO
				,t1.unitCode
				,c.GUID_Case
				,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=GETDATE()
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=7 and r.ReportMonth<=9 and
				r.ReportYear=2013
				and cb.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join dbo.vw_sprMU t1 on
				m.MUCode=t1.MU			
				and t1.unitCode=3
						inner join @p p on
				cb.id=p.id													
		group by c.rf_idMO,t1.unitCode,c.GUID_Case		
		) t
group by t.rf_idMO,t.unitCode,t.GUID_Case

select t.rf_idMO,t.GUID_Case,t.unitCode,SUM(t.Quantity) AS Quantity
INTO #tmp_PlanOrder_Account
from (
		select c.rf_idMO
				,t1.unitCode
				,c.GUID_Case
				,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from AccountOMS.dbo.t_File f inner join AccountOMS.dbo.t_RegistersAccounts r on
				f.id=r.rf_idFiles		
				and f.DateRegistration>'20130701' AND f.DateRegistration<GETDATE()
				AND r.rf_idSMO IN ('34001','34002')
				AND f.CodeM=@codeLPU
						  inner join AccountOMS.dbo.t_RecordCasePatient cb on
				cb.rf_idRegistersAccounts=r.id and
				r.ReportMonth>=7 and r.ReportMonth<=9 and
				r.ReportYear=2013				
						inner join AccountOMS.dbo.t_Case c on
				c.rf_idRecordCasePatient=cb.id
						inner join AccountOMS.dbo.t_Meduslugi m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join AccountOMS.dbo.vw_sprMU t1 on
				m.MUGroupCode=t1.MUGroupCode
				AND m.MUUnGroupCode=t1.MUUnGroupCode
				AND m.MUCode=t1.MUCode
				and t1.unitCode=3					
		group by c.rf_idMO,t1.unitCode,c.GUID_Case		
		) t
group by t.rf_idMO,t.unitCode,t.GUID_Case

SELECT *
FROM #tmp_PlanOrder_Case p1 left JOIN #tmp_PlanOrder_Account p2 ON
						p1.GUID_Case=p2.Guid_Case
WHERE p2.Guid_Case IS NULL