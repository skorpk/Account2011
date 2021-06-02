use RegisterCases
go
select fb.rf_idFiles,r.*
from t_FileBack fb inner join t_RegisterCaseBack r on
			fb.id=r.rf_idFilesBack
			and r.PropertyNumberRegister in (1,0)
					left join t_PlanOrdersReport p on
			fb.id=p.rf_idFileBack
			and fb.rf_idFiles=p.rf_idFile
where p.rf_idFile is null


declare @plan TABLE
					(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred int
					)
declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred int
					)
--план заказов расчитывается по новому с 2011-12-12. В качестве отчетного месяца бере максимальный месяц из реестра сведений с оплатой 1
-- и сравниваем с @month и берем из них максимальное значения для фильтрации.
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@year smallint=2011,
		@codeLPU char(6)

-------------------------------------------------------------------------------------
declare @t as table(MonthID tinyint,QuarterID tinyint,partitionQuarterID tinyint)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3)
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
insert @plan1(CodeLPU,UnitCode,Vm,Vdm)
 select left(t1.tfomsCode,6),t1.unitCode,t1.V+isnull(t2.Vt,0)+isnull(t2.O,0)+isnull(t3.Vkm,0),isnull(t3.Vdm,0)--,t1.V,t2.Vt,t2.O,t3.Vkm
	from (
		select mo.tfomsCode,SUM(pl.rate) as V,pu.unitCode
		from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
					py.rf_MOId=mo.MOId and
					py.[year]=@year
						inner join oms_NSI.dbo.tPlan pl on
					py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
						inner join oms_NSI.dbo.tPlanUnit pu on
					pl.rf_PlanUnitId=pu.PlanUnitId
						inner join @t t on
					pl.rf_QuarterId<t.QuarterID				
		where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@monthMax
		group by mo.tfomsCode,pu.unitCode
		) t1 left join (
							select mo.tfomsCode,pu.unitCode,(t.partitionQuarterID*(cast(SUM(pl.rate)/3 as int))) as Vt,SUM(pl.rate)-3*cast(SUM(pl.rate)/3 as int) as O
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and 
										pl.flag='A'
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId				
											inner join @t t on
										pl.rf_QuarterId=t.QuarterID
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@monthMax
							group by mo.tfomsCode,pu.unitCode,t.partitionQuarterID
							) t2 on
		t1.tfomsCode=t2.tfomsCode and
		t1.unitCode=t2.unitCode
			left join (
						select mo.tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
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
									pl.PlanId=pc.rf_PlanId and pc.rf_MonthId<=@monthMax
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t3 on
		t1.tfomsCode=t3.tfomsCode and
		t1.unitCode=t3.unitCode
---------------расчет Sпред--------------------------------------------
declare @tS as table(CodeLPU char(6),unitCode tinyint,Rate int)
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
insert @tS
select c.rf_idMO
		,t1.unitCode
		,SUM(m.Quantity) as Quantity
from t_Case c inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
				inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
				inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth=@monthMax and
		r.ReportYear=@year
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join t_PatientBack p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
group by c.rf_idMO,t1.unitCode			
			
--insert @tS select CodeLPU,unitCode,RATE from t_PlanOrders2011 where CodeLPU=@codeLPU 
insert @tS
select CodeLPU,unitCode,SUM(Rate)
from t_PlanOrders2011 
where CodeLPU=@codeLPU and MonthRate<=@monthMax
group by CodeLPU,unitCode
--------------------------------------------------------------------------------------
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.CodeLPU,t.unitCode,0,0,t.Rate
from @tS t
	
insert @plan(CodeLPU,UnitCode,Vm,Vdm,Spred)
select CodeLPU,UnitCode,sum(Vm),sum(Vdm),isnull(sum(Spred),0)
from @plan1 
group by CodeLPU,UnitCode
		