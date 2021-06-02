use RegisterCases
go
if OBJECT_ID('usp_GetPlanOrders',N'P') is not null
	drop procedure usp_GetPlanOrders 
go
create proc usp_GetPlanOrders 
		@codeLPU varchar(6)
		,@month tinyint
		,@year smallint
as

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
declare @monthMax tinyint

select @monthMax=case when max(t.MonthRate)>@month then max(t.MonthRate) else @month end
from(
		select isnull(MAX(rc.ReportMonth),@month) as MonthRate 
		from t_FileBack f inner join t_RegisterCaseBack rc on
					f.id=rc.rf_idFilesBack
					--	  inner join oms_nsi.dbo.vw_sprT001 v on
					--f.CodeM=v.CodeM
								inner join t_RecordCaseBack rb on
					rc.id=rb.rf_idRegisterCaseBack
								inner join t_CaseBack cb on
					rb.id=cb.rf_idRecordCaseBack
							and cb.TypePay=1
								inner join t_PatientBack p on
					rb.id=p.rf_idRecordCaseBack
								inner join vw_sprSMO s on
					p.rf_idSMO=s.smocod
		where f.CodeM=@codeLPU and rc.ReportYear=@year
		union all
		select MAX(MonthRate) from t_PlanOrders2011 where CodeLPU=@codeLPU and YearRate=@year
	) t

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
--------------------------------------------------------------------------------------------------------------------------------
declare @tPlan as table(tfomsCode char(6),unitCode tinyint,Vkm bigint,Vdm bigint, Vt bigint,O bigint,V bigint)
insert @tPlan(tfomsCode,unitCode)
select @codeLPU, unitCode
from oms_NSI.dbo.tPlanUnit


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
									pl.PlanId=pc.rf_PlanId and pc.rf_MonthId<=@monthMax
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode

update @tPlan
set Vt=t.Vt, O=t.O
from @tPlan p inner join (						
							select left(mo.tfomsCode,6) as tfomsCode,pu.unitCode,(t.partitionQuarterID*(cast(SUM(pl.rate)/3 as int))) as Vt,
									SUM(pl.rate)-3*cast(SUM(pl.rate)/3 as int) as O
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
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode


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
										pl.rf_QuarterId<t.QuarterID				
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@monthMax
							group by mo.tfomsCode,pu.unitCode
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode

insert @plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from @tPlan p
 
declare @tS as table(CodeLPU char(6),unitCode tinyint,Rate int)
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
insert @tS
select c.rf_idMO
		,t1.unitCode
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_Case c inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
		--		inner join t_RecordCase rc on
		--c.rf_idRecordCase=rc.id
		--		inner join t_RegistersCase r on
		--rc.rf_idRegistersCase=r.id and
		--r.ReportMonth>0 and r.ReportMonth<=@monthMax and
		--r.ReportYear=@year
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase		
				inner join (select rf_idRecordCaseBack,rf_idSMO 
							from t_PatientBack
							group by rf_idRecordCaseBack,rf_idSMO 
							) p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on			
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
				inner join t_RegisterCaseBack rb on
		cb.rf_idRegisterCaseBack=rb.id
		and rb.ReportMonth<=@monthMax 
		and rb.ReportYear=@year
group by c.rf_idMO,t1.unitCode		
			
--insert @tS select CodeLPU,unitCode,RATE from t_PlanOrders2011 where CodeLPU=@codeLPU 
insert @tS
select CodeLPU,unitCode,SUM(Rate)
from t_PlanOrders2011 
where CodeLPU=@codeLPU and MonthRate<=@monthMax and YearRate=@year
group by CodeLPU,unitCode
--------------------------------------------------------------------------------------
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.CodeLPU,t.unitCode,0,0,t.Rate
from @tS t
	
select CodeLPU,UnitCode,sum(Vm),sum(Vdm),isnull(sum(Spred),0),@monthMax
from @plan1 
group by CodeLPU,UnitCode
	
go