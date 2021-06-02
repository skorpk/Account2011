DECLARE @codeLPU VARCHAR(6)='805934',
		@month TINYINT=12,
		@year SMALLINT=2019

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
				--and cp.TypePay=1
			inner loop join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=GETDATE() AND r.NumberRegister=942

CREATE CLUSTERED INDEX IX_idCase on #p(id)
------------------------------------------------------------ 
---Изменения от 27.11.2013 добавился период действия единиц учета
DECLARE @tS AS TABLE(CodeLPU CHAR(6),unitCode SMALLINT,Rate DECIMAL(11,2))
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU1 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=1
SELECT MU, ChildUET,AdultUET, beginDate, endDate, unitCode INTO #tMU2 FROM dbo.vw_sprMU WHERE unitCode IS NOT NULL AND calculationType=2

CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU1(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)
CREATE NONCLUSTERED INDEX IX_MU1 ON #tMU2(MU,beginDate,endDate) INCLUDE(ChildUET,AdultUET,unitCode)


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
								INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET,beginDate AS DateBeg,endDate AS DateEnd FROM dbo.vw_sprMU WHERE calculationType=2 
											UNION ALL 
											SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET,DateBeg,DateEnd FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
											) t1 ON
						m.MES=t1.MU			
						AND t1.unitCode IS NOT NULL
								INNER JOIN #p  p ON
						c.id=p.id									
				WHERE cc.DateEnd>= t1.beginDate AND cc.DateEnd<=t1.endDate AND cc.DateEnd>= t1.DateBeg AND cc.DateEnd<=t1.DateEnd--добавил фильтр по дате действия единиц учета
			) t
			GROUP BY t.rf_idMO,t.unitCode
GO

DROP TABLE #p
DROP TABLE #tMU1
DROP TABLE #tMU2


