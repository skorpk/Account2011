use RegisterCases
go
if OBJECT_ID('usp_PlanOrdersReportNew',N'P') is not null
drop proc usp_PlanOrdersReportNew
go
create procedure usp_PlanOrdersReportNew
				@idFile int=null,
				@idFileBack int
as
SET LANGUAGE russian
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate datetime
--присваеваю параметрам данные из таблиц реестра СП и ТК
--select * from t_FileBack where id=@idFileBack

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
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then 'первый'
								when QuarterID=2 then 'второй' 
								when QuarterID=1 then 'третий' else 'четвертый' end)
)
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

 
--declare @tS as table(CodeLPU char(6),unitCode tinyint,Rate int)
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
--insert @ts
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select c.rf_idMO
		,t1.unitCode
		,0,0
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
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
group by c.rf_idMO,t1.unitCode
	
--------------------------------------------------------------------------------------
--insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
--select t.CodeLPU,t.unitCode,0,0,t.Rate
--from @tS t
	
select u.unitCode
		,u.unitName
		,p.Vdm as MEK
		,p.Vm as Utv
		,p.Spred
		,p.Spred-(p.Vdm+p.Vm) as Diff
		,(select QuarterName from @t where MonthID=@month) as ReportDate
		,v.NameS as LPU
		, @number as NumberRegister
		,cast(p.Spred as decimal(15,2))/(case when p.Vdm+p.Vm=0 then 1 else cast((p.Vdm+p.Vm) as decimal(15,2))end) as [Percent]
from (
		select CodeLPU,UnitCode,cast(sum(Vm) as decimal(11,2)) as Vm,cast(sum(Vdm) as decimal(11,2)) as Vdm
				,isnull(sum(Spred),0)  as Spred
		from @plan1 
		group by CodeLPU,UnitCode
	 ) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode
		 inner join oms_nsi.dbo.vw_sprT001 v on
			p.CodeLPU=v.CodeM	
where p.Spred>0
order by 1
go