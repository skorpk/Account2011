USE RegisterCases
GO
DECLARE @codeLPU VARCHAR(6)='121018' ,
		@monthMin TINYINT=1,
		@monthMax TINYINT=3,
		@year SMALLINT=2017,
		@dateCreate DATETIME=GETDATE(),
		@dateStart DATETIME='20170102'

declare @p as table(id int)
insert @p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
			--AND r.NumberRegister=94
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=@dateCreate

--DROP TABLE tmpCases159
;WITH ctePlan AS
(
select /*c.rf_idMO
		,c.GUID_Case
		,t1.unitCode
		,*/f.DateCreate,c.idRecordCase,c.Age,r.NumberRegister,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
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
				inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU 
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit
							) t1 on
		m.MES=t1.MU			
		and t1.unitCode is not null
				inner join @p p on
		cb.id=p.id					            
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.unitCode=144 AND NumberRegister=94
GROUP BY f.DateCreate,c.idRecordCase,c.Age, r.NumberRegister
UNION ALL
select /*c.rf_idMO
		,c.GUID_Case
		,t1.unitCode
		,*/f.DateCreate,c.idRecordCase,c.Age,r.NumberRegister,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
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
				inner join dbo.t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				INNER JOIN dbo.vw_sprMU t1 ON
		m.MUCode=t1.MU			
		AND t1.unitCode IS NOT NULL
				inner join @p p on
		cb.id=p.id					            
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.unitCode=144 AND NumberRegister=94
GROUP BY f.DateCreate,c.idRecordCase,c.Age,r.NumberRegister
)
SELECT DateCreate,idRecordCase,Age,NumberRegister,SUM(Quantity) AS qu FROM ctePlan GROUP BY DateCreate,idRecordCase,Age,NumberRegister ORDER BY DateCreate,qu desc


--select /*c.rf_idMO
--		,c.GUID_Case
--		,t1.unitCode
--		,*/f.DateCreate,r.NumberRegister,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
--from t_FileBack f inner join t_RegisterCaseBack r on
--		f.id=r.rf_idFilesBack		
--		and f.DateCreate<=@dateCreate
--				  inner join t_RecordCaseBack cb on
--		cb.rf_idRegisterCaseBack=r.id and
--		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
--		r.ReportYear=@year
--				INNER JOIN dbo.t_CaseBack cp ON
--		cb.id=cp.rf_idRecordCaseBack					
--		and cp.TypePay=1
--				inner join t_Case c on
--		c.id=cb.rf_idCase
--				inner join t_MES m on
--		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
--				inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU 
--							UNION ALL 
--							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit
--							) t1 on
--		m.MES=t1.MU			
--		and t1.unitCode is not null
--				inner join @p p on
--		cb.id=p.id					            
--WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.unitCode=144 AND NumberRegister=94
--GROUP BY f.DateCreate, r.NumberRegister

--SELECT f.DateCreate,r.NumberRegister,c,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
--from t_FileBack f inner join t_RegisterCaseBack r on
--		f.id=r.rf_idFilesBack		
--		and f.DateCreate<=@dateCreate
--				  inner join t_RecordCaseBack cb on
--		cb.rf_idRegisterCaseBack=r.id and
--		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
--		r.ReportYear=@year
--				INNER JOIN dbo.t_CaseBack cp ON
--		cb.id=cp.rf_idRecordCaseBack					
--		and cp.TypePay=1
--				inner join t_Case c on
--		c.id=cb.rf_idCase
--				inner join dbo.t_Meduslugi m on
--		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
--				INNER JOIN dbo.vw_sprMU t1 ON
--		m.MUCode=t1.MU			
--		AND t1.unitCode IS NOT NULL
--				inner join @p p on
--		cb.id=p.id					            
--WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.unitCode=144  AND NumberRegister=94
--GROUP BY f.DateCreate,r.NumberRegister

--;WITH tmp
--AS(
--select c.rf_idMO
--		,c.GUID_Case
--		,t1.unitCode
--		,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
----INTO tmpCases159
--from t_FileBack f inner join t_RegisterCaseBack r on
--		f.id=r.rf_idFilesBack		
--		and f.DateCreate<=@dateCreate
--				  inner join t_RecordCaseBack cb on
--		cb.rf_idRegisterCaseBack=r.id and
--		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
--		r.ReportYear=@year
--				INNER JOIN dbo.t_CaseBack cp ON
--		cb.id=cp.rf_idRecordCaseBack					
--		and cp.TypePay=1
--				inner join t_Case c on
--		c.id=cb.rf_idCase
--				inner join t_MES m on
--		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
--				inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU 
--							UNION ALL 
--							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit
--							) t1 on
--		m.MES=t1.MU			
--		and t1.unitCode is not null
--				inner join @p p on
--		cb.id=p.id					            
--WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.unitCode=159
--group by c.rf_idMO,c.GUID_Case,t1.unitCode	
--)
--SELECT c.*,ac.id
----INTO tmpCases159
--FROM tmp c INNER JOIN AccountOMS.dbo.t_Case ac  ON
--		c.GUID_Case=ac.GUID_Case  