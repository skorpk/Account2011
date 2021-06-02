USE [RegisterCases]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_PlanOrders]    Script Date: 03/12/2012 16:36:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_PlanOrders]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_PlanOrders]
GO

USE [RegisterCases]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_PlanOrders]    Script Date: 03/12/2012 16:36:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_PlanOrders](@codeLPU varchar(6),@month tinyint,@year smallint)
RETURNS @plan TABLE
					(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred decimal(11,2),
						[month] tinyint
					)
AS
begin
declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2011-12-12. В качестве отчетного месяца бере максимальный месяц из реестра сведений с оплатой 1
-- и сравниваем с @month и берем из них максимальное значения для фильтрации.

--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table(MonthID tinyint,QuarterID tinyint,partitionQuarterID tinyint)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month				
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится 
--на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3) c 24.02.2012 он не нужен т.к. расчет идет покрватально
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
									pl.PlanId=pc.rf_PlanId 
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
 
declare @tS as table(CodeLPU char(6),unitCode tinyint,Rate decimal(11,2))
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
--insert @tS
--select c.rf_idMO
--		,t1.unitCode
--		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
--from t_RegisterCaseBack r inner join t_RecordCaseBack cb on
--		cb.rf_idRegisterCaseBack=r.id and
--		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
--		r.ReportYear=@year
--				inner join t_Case c on
--		c.id=cb.rf_idCase
--				inner join t_Meduslugi m on
--		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
--				inner join dbo.vw_sprMU t1 on
--		m.MUCode=t1.MU			
--				inner join (
--							select rf_idRecordCaseBack,rf_idSMO 
--							from t_PatientBack
--							group by rf_idRecordCaseBack,rf_idSMO 
--							) p on
--		cb.id=p.rf_idRecordCaseBack
--				inner join vw_sprSMO s on
--			p.rf_idSMO=s.smocod
--				inner join t_CaseBack ct on
--		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
--group by c.rf_idMO,t1.unitCode
insert @ts
select c.rf_idMO
		,t1.unitCode
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU			
				inner join (
							select rf_idRecordCaseBack,rf_idSMO 
							from t_PatientBack
							group by rf_idRecordCaseBack,rf_idSMO 
							) p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
where f.DateCreate<=GETDATE()
group by c.rf_idMO,t1.unitCode
			
insert @tS
select CodeLPU,unitCode,SUM(Rate)
from t_PlanOrders2011 
where CodeLPU=@codeLPU and MonthRate>=@monthMin and MonthRate<=@monthMax and YearRate=@year
group by CodeLPU,unitCode
--------------------------------------------------------------------------------------
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.CodeLPU,t.unitCode,0,0,t.Rate
from @tS t
	
insert @plan(CodeLPU,UnitCode,Vm,Vdm,Spred,[month])
select CodeLPU,UnitCode,sum(Vm),sum(Vdm),isnull(sum(Spred),0),(select t.QuarterID from @t t where t.MonthID=@month)
from @plan1 
group by CodeLPU,UnitCode
		
	RETURN
end;

GO

