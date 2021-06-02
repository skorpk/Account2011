USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetPlanOrders]    Script Date: 18.12.2018 10:51:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetPlanOrders]
				@idFile INT,
				@idFileBack INT
AS
---для внесения пропущенных данных в таблицу t_PlanOrders		
SET LANGUAGE russian
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate DATETIME,
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

declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin TINYINT
  
        
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
declare @tPlan as table(tfomsCode char(6),unitCode SMALLINT,Vkm bigint,Vdm bigint, Vt bigint,O bigint,V bigint)
insert @tPlan(tfomsCode,unitCode) select @codeLPU, unitCode from oms_NSI.dbo.tPlanUnit

update @tPlan
set Vkm=t.Vkm,Vdm=t.Vdm
from @tPlan p inner join (
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


update @tPlan
set V=t.V
from @tPlan p inner join (						
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

insert @plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from @tPlan p

CREATE TABLE #p (id int)
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
			INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=@dateCreate
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU1 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=1
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU2 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=2

CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU1(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)
CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU2(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)

--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
---Изменения от 27.12.2017 добавился вид расчета
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.rf_idMO,t.unitCode,0,0,SUM(t.Quantity)
from (			
		SELECT c.rf_idMO
		,t1.unitCode
		,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
		FROM t_Case c INNER JOIN t_Meduslugi m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
						INNER JOIN #tMU1 t1 ON
				m.MUCode=t1.MU					
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate 
		GROUP BY c.rf_idMO,t1.unitCode
		UNION ALL
		SELECT c.rf_idMO
				,t1.unitCode
				,COUNT(DISTINCT c.id) AS Quantity
		FROM t_Case c INNER JOIN t_Meduslugi m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
						INNER JOIN #tMU2 t1 ON
				m.MUCode=t1.MU			
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate 
		GROUP BY c.rf_idMO,t1.unitCode	
		UNION all		
		SELECT c.rf_idMO
				,t1.unitCode
				,COUNT(DISTINCT c.id) AS Quantity
		FROM t_Case c INNER JOIN t_MES m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
				and c.IsCompletedCase=1
						INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=2 
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
									) t1 ON
				m.MES=t1.MU			
				AND t1.unitCode IS NOT NULL
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
		GROUP BY c.rf_idMO,t1.unitCode		
		---Completed case
		--добавил вычисление по КСГ
		UNION ALL
		SELECT c.rf_idMO
				,t1.unitCode
				,SUM(CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
		FROM t_Case c INNER JOIN t_MES m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
				and c.IsCompletedCase=1
						INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1 
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
									) t1 ON
				m.MES=t1.MU			
				AND t1.unitCode IS NOT NULL
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
		GROUP BY c.rf_idMO,t1.unitCode			
		) t
group by t.rf_idMO,t.unitCode




SELECT @idFile,@idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,@month,@year FROM @plan1 where Vm+Spred+Vdm>0
