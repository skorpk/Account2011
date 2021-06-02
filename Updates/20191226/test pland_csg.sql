USE RegisterCases
GO

DECLARE @idFile int=null,
				@idFileBack int

SELECT @idFileBack=idFileBack
FROM dbo.vw_getFileBack WHERE CodeM='101201' AND ReportYear=2019 AND NumberRegister=104

SET LANGUAGE russian
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate datetime,
		@dateStart DATETIME
--присваеваю параметрам данные из таблиц реестра СП и ТК
select @number=cast(rc.NumberRegister as varchar(13))+'-'+cast(rc.PropertyNumberRegister as CHAR(1))
		,@dateCreate=fb.DateCreate
		,@month=rc.ReportMonth
		,@year=rc.ReportYear
		,@codeLPU=fb.CodeM
from t_RegisterCaseBack rc inner join t_FileBack fb on
			rc.rf_idFilesBack=fb.id
where fb.id=@idFileBack

CREATE TABLE #plan1(
						CodeLPU varchar(6),
						UnitCode int,
						Vm DECIMAL(11,2),
						Vdm DECIMAL(11,2),
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then 'первый квартал'
								when QuarterID=2 then 'второй квартал' 
								when QuarterID=3 then 'третий квартал' else 'четвертый квартал' end)
)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month	

SET @dateStart=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@monthMin AS varCHAR(2)),2)+'01'			
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится 
--на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3) c 24.02.2012 он не нужен т.к. расчет идет покрватально
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
--------------------------------------------------------------------------------------------------------------------------------
CREATE table #tPlan(tfomsCode char(6),unitCode SMALLINT,Vkm DECIMAL(11,2),Vdm DECIMAL(11,2), Vt DECIMAL(11,2),O DECIMAL(11,2),V DECIMAL(11,2))
insert #tPlan(tfomsCode,unitCode) select @codeLPU, unitCode from oms_NSI.dbo.tPlanUnit
CREATE NONCLUSTERED INDEX ix_1 ON #tPlan(tfomsCode,unitCode)

update #tPlan
set Vkm=t.Vkm,Vdm=t.Vdm
from #tPlan p inner join (
						select left(mo.tfomsCode,6) as tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
								sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
						from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
									py.rf_MOId=mo.MOId and
									py.[year]=@year
										inner join oms_NSI.dbo.tPlan pl on
									py.PlanYearId=pl.rf_PlanYearId and 
									pl.flag='A'
										inner join oms_NSI.dbo.tPlanUnit pu on
									pl.rf_PlanUnitId=pu.PlanUnitId
										left join oms_NSI.dbo.tPlanCorrection pc on
									pl.PlanId=pc.rf_PlanId and pc.flag='A'
									and pc.rf_MonthId>=@monthMin and pc.rf_MonthId<=@monthMax 
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode


update #tPlan
set V=t.V
from #tPlan p inner join (						
							select left(mo.tfomsCode,6) as tfomsCode,SUM(pl.rate) as V,pu.unitCode
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId
											inner join @t t on
										pl.rf_QuarterId=t.QuarterID				
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@month
							group by mo.tfomsCode,pu.unitCode
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode

insert #plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from #tPlan p

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
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=@dateCreate --AND r.NumberRegister=93
--OPTION(MAXDOP 4)				

SELECT calculationType,MU, beginDate, endDate,unitCode,ChildUET,AdultUET
INTO #tmpMU
FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL

CREATE NONCLUSTERED INDEX IX_MU ON #tmpMU(MU,beginDate, endDate,calculationType)
INCLUDE(ChildUET,AdultUET, unitCode)

----------------------------------------Медуслуги-------------------------------
SELECT COUNT(id),COUNT(DISTINCT id) FROM #p 

		SELECT c.rf_idMO
				,t1.unitCode				
				,r.NumberRegister
				,f.id
				,COUNT(DISTINCT c.rf_idRecordCase )as Quantity
		from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
				r.ReportYear=@year
				AND r.ReportYear>2018
						INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						INNER JOIN dbo.t_CompletedCase cc ON
				c.rf_idRecordCase=cc.rf_idRecordCase
						inner join t_MES m on
				c.id=m.rf_idCase and c.rf_idMO=@codeLPU
						inner join (SELECT DISTINCT MU,beginDate,endDate,unitCode,beginDate AS DateBeg,endDate AS DateEnd FROM dbo.vw_sprMU WHERE calculationType=2
									UNION ALL 
									SELECT DISTINCT CSGCode AS MU,beginDate,endDate,UnitCode,dateBeg,dateEnd FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2 
									) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null
						inner join #p p on
				cb.id=p.id							
		WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate AND cc.DateEnd>= t1.DateBeg AND cc.DateEnd<=t1.DateEnd 
		GROUP BY c.rf_idMO,t1.unitCode,r.NumberRegister,f.id
GO
DROP TABLE #p
go
DROP TABLE #tPlan
go
DROP TABLE #Plan1
go
DROP TABLE #tmpMU
