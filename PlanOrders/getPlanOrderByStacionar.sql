USE RegisterCases
GO
DECLARE @codeLPU CHAR(6)='531001',
		@dateCreate DATETIME=GETDATE(),
		@monthMin TINYINT=1,
		@monthMax TINYINT=3,
		@year SMALLINT=2018

CREATE table #p (id int)
insert #p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>='20180125' AND f.DateCreate<=GETDATE() 

select t.rf_idMO,t.NumberRegister,CAST(SUM(t.Quantity) AS INT) AS CountUnit
from (
		select c.rf_idMO
				,t1.unitCode
				,r.NumberRegister
				,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND c.rf_idV006=1 
		group by c.rf_idMO,t1.unitCode,r.NumberRegister		
		UNION ALL ---new algorithm since 27.12.2017
		select c.rf_idMO
				,t1.unitCode
				,r.NumberRegister
				,COUNT(DISTINCT c.id) as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT MU,beginDate,endDate,unitCode FROM dbo.vw_sprMU WHERE calculationType=2
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND c.rf_idV006=1
		group by c.rf_idMO,t1.unitCode,r.NumberRegister		      
		) t
group by t.rf_idMO,t.NumberRegister
--------------------------------------------------------------------------------------
GO
DROP TABLE #p
