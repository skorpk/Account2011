USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_PlanOrders]    Script Date: 02.04.2019 14:42:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_PlanOrders]
		@codeLPU VARCHAR(6),@month TINYINT,@year SMALLINT
AS
DECLARE @plan1 TABLE(
						CodeLPU VARCHAR(6),
						UnitCode INT,
						Vm DECIMAL(11,2),
						Vdm DECIMAL(11,2),
						Spred DECIMAL(11,2)
					)
--план заказов расчитывается по новому с 2011-12-12. В качестве отчетного месяца бере максимальный месяц из реестра сведений с оплатой 1
-- и сравниваем с @month и берем из них максимальное значения для фильтрации.

--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
DECLARE @monthMax TINYINT,
		@monthMin TINYINT,
		@dateStart DATETIME


		
-------------------------------------------------------------------------------------
DECLARE @t AS TABLE(MonthID TINYINT,QuarterID TINYINT,partitionQuarterID TINYINT)
INSERT @t VALUES(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
SELECT @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
FROM @t t INNER JOIN @t t1 ON
		t.QuarterID=t1.QuarterID
WHERE t.MonthID=@month		

--declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@monthMin as varchar(2)),2)+'01'
--declare @dateEnd1 date=CAST(@year as CHAR(4))+right('0'+CAST(@monthMin as varchar(2)),2)+'01'

--declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateEnd1),@dateEnd1))	

		
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится 
--на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3) c 24.02.2012 он не нужен т.к. расчет идет покрватально
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @tPlan AS TABLE(tfomsCode CHAR(6),unitCode SMALLINT,Vkm DECIMAL(11,2),Vdm DECIMAL(11,2), Vt DECIMAL(11,2),O DECIMAL(11,2),V DECIMAL(11,2))
INSERT @tPlan(tfomsCode,unitCode)
SELECT @codeLPU, unitCode
FROM oms_NSI.dbo.tPlanUnit


UPDATE @tPlan
SET Vkm=t.Vkm,Vdm=t.Vdm
FROM @tPlan p INNER JOIN (
						SELECT LEFT(mo.tfomsCode,6) AS tfomsCode,pu.unitCode,SUM(CASE WHEN pc.mec=0 THEN ISNULL(pc.correctionRate,0) ELSE 0 END) AS Vkm,
								SUM(CASE WHEN pc.mec=1 THEN ISNULL(pc.correctionRate,0) ELSE 0 END) AS Vdm
						FROM oms_NSI.dbo.tPlanYear py INNER JOIN oms_NSI.dbo.tMO mo ON
									py.rf_MOId=mo.MOId AND
									py.[year]=@year
										INNER JOIN oms_NSI.dbo.tPlan pl ON
									py.PlanYearId=pl.rf_PlanYearId AND 
									pl.flag='A'
										INNER JOIN oms_NSI.dbo.tPlanUnit pu ON
									pl.rf_PlanUnitId=pu.PlanUnitId
										LEFT JOIN oms_NSI.dbo.tPlanCorrection pc ON
									pl.PlanId=pc.rf_PlanId AND pc.flag='A'
									AND pc.rf_MonthId>=cast(@monthMin as bigint) AND pc.rf_MonthId<=cast(@monthMax as bigint)
						WHERE LEFT(mo.tfomsCode,6)=@codeLPU 
						GROUP BY mo.tfomsCode,pu.unitCode
						) t ON p.tfomsCode=t.tfomsCode AND p.unitCode=t.unitCode


UPDATE @tPlan
SET V=t.V
FROM @tPlan p INNER JOIN (						
							SELECT LEFT(mo.tfomsCode,6) AS tfomsCode,SUM(pl.rate) AS V,pu.unitCode
							FROM oms_NSI.dbo.tPlanYear py INNER JOIN oms_NSI.dbo.tMO mo ON
										py.rf_MOId=mo.MOId AND
										py.[year]=@year
											INNER JOIN oms_NSI.dbo.tPlan pl ON
										py.PlanYearId=pl.rf_PlanYearId AND pl.flag='A'
											INNER JOIN oms_NSI.dbo.tPlanUnit pu ON
										pl.rf_PlanUnitId=pu.PlanUnitId
											INNER JOIN @t t ON
										pl.rf_QuarterId=t.QuarterID				
							WHERE LEFT(mo.tfomsCode,6)=@codeLPU AND t.MonthID=cast(@month as bigint)
							GROUP BY mo.tfomsCode,pu.unitCode
						) t ON  p.tfomsCode=t.tfomsCode AND p.unitCode=t.unitCode

INSERT @plan1(CodeLPU,UnitCode,Vm,Vdm)
SELECT p.tfomsCode,p.unitCode,ISNULL(p.V,0)+ISNULL(p.Vt,0)+ISNULL(p.O,0)+ISNULL(p.Vkm,0),ISNULL(p.Vdm,0)
FROM @tPlan p
 
SET @dateStart=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@monthMin AS VARCHAR(2)),2)+'01' 

CREATE TABLE #p (id int)
------------------------------------------------------------
insert #p 
SELECT distinct cb.rf_idCase
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year			
			INNER JOIN dbo.t_CaseBack cp ON
				cb.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
			inner loop join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=GETDATE()
CREATE CLUSTERED INDEX IX_idCase on #p(id)
------------------------------------------------------------ 
---Изменения от 27.11.2013 добавился период действия единиц учета
DECLARE @tS AS TABLE(CodeLPU CHAR(6),unitCode SMALLINT,Rate DECIMAL(11,2))
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU1 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=1
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU2 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=2

CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU1(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)
CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU2(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)

INSERT @ts
SELECT c.rf_idMO
		,t1.unitCode
		,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM t_Case c INNER JOIN t_Meduslugi m ON
		c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
				INNER JOIN #tMU1 t1 ON
		m.MUCode=t1.MU			
		--AND t1.unitCode IS NOT NULL
				INNER JOIN #p  p ON
		c.id=p.id									
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND t1.calculationType=1
GROUP BY c.rf_idMO,t1.unitCode

---Completed case
--добавил вычисление по КСГ
insert @ts
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


 IF @year<2019	--считаем на уровне таблицы t_Case
 BEGIN
		INSERT @ts
		SELECT c.rf_idMO
				,t1.unitCode
				,COUNT(DISTINCT c.id) AS Quantity
		FROM t_Case c INNER JOIN t_Meduslugi m ON
				c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
						INNER JOIN #tMU2 t1 ON
				m.MUCode=t1.MU			
				--AND t1.unitCode IS NOT NULL
						INNER JOIN #p  p ON
				c.id=p.id									
		WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND t1.calculationType=2
		GROUP BY c.rf_idMO,t1.unitCode
		insert @ts
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
 END
 ELSE
  BEGIN
		INSERT @ts
		SELECT t.rf_idMO,t.unitCode,COUNT(DISTINCT Quantity)
		FROM (
				SELECT c.rf_idMO
						,t1.unitCode
						,cc.id AS Quantity
				FROM dbo.t_CompletedCase cc INNER JOIN t_Case c ON
						cc.rf_idRecordCase=c.rf_idRecordCase
											INNER JOIN t_Meduslugi m ON
						c.id=m.rf_idCase AND c.rf_idMO=@codeLPU		
								INNER JOIN #tMU2 t1 ON
						m.MUCode=t1.MU			
						--AND t1.unitCode IS NOT NULL
								INNER JOIN #p  p ON
						c.id=p.id									
				WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate --AND t1.calculationType=2
				UNION  all
				SELECT c.rf_idMO
						,t1.unitCode
						,cc.id AS Quantity
				FROM dbo.t_CompletedCase cc INNER JOIN t_Case c ON
						cc.rf_idRecordCase=c.rf_idRecordCase
											INNER JOIN t_MES m ON
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
				WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
			) t
			GROUP BY t.rf_idMO,t.unitCode
end



if @year=2011			
begin
	INSERT @tS SELECT CodeLPU,unitCode,SUM(Rate)FROM t_PlanOrders2011 
	WHERE CodeLPU=@codeLPU AND MonthRate>=@monthMin AND MonthRate<=@monthMax AND YearRate=@year GROUP BY CodeLPU,unitCode
end
--------------------------------------------------------------------------------------
INSERT @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
SELECT t.CodeLPU,t.unitCode,0,0,t.Rate
FROM @tS t

insert #tmpPlan(CodeLPU,UnitCode,Vm,Vdm,Spred,[month])	
SELECT CodeLPU,UnitCode,SUM(Vm),SUM(Vdm),ISNULL(SUM(Spred),0),(SELECT t.QuarterID FROM @t t WHERE t.MonthID=@month)
FROM @plan1 GROUP BY CodeLPU,UnitCode
DROP TABLE #p

