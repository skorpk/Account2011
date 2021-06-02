use RegisterCases
go
if OBJECT_ID('usp_PlanOrdersReportTotal',N'P') is not null
drop proc usp_PlanOrdersReportTotal
go
create procedure usp_PlanOrdersReportTotal
				@dateReg datetime,
				@Quarter tinyint,
				@year smallint
as
SET LANGUAGE russian

declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm decimal(11,2),
						Vdm decimal(11,2),
						Vkm decimal(11,2),
						Spred decimal(11,2)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
--переопределяю переменную @dateReg если пользователь указал большую дату чем нынешний момент времени
select @dateReg=(case when @dateReg>GETDATE() then GETDATE() else @dateReg end)
declare @dateBeg datetime=CAST(@year as CHAR(4))+'0101'
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
where t.QuarterID=@Quarter				

--------------------------------------------------------------------------------------------------------------------------------
declare @tPlan as table(tfomsCode char(6),unitCode tinyint,Vkm DECIMAL(11,2),Vdm DECIMAL(11,2),V bigint,Spred decimal(11,2))

insert @tPlan(tfomsCode,unitCode,Spred) 
SELECT f.CodeM,p.UnitCode,MAX(p.Spred)
FROM dbo.t_PlanOrdersReport p INNER JOIN t_FileBack f WITH (INDEX (IX_DateCreate_ID_CodeM)) ON	
			p.rf_idFileBack=f.id 
							 inner join t_RegisterCaseBack a on
		f.id=a.rf_idFilesBack			
where f.DateCreate<=@dateReg and a.ReportMonth>=@monthMin and a.ReportMonth<=@monthMax and a.ReportYear=@year AND p.TotalVm>0
group by CodeM,unitCode
--заменил на действующие данные. теперь не надо хранить сведения о выполненом плане заказе в отдельно БД.
--select CodeM,unitCode,SUM(Quantity)
--from RegisterCasesDW.dbo.t_PlanOrdersFact 
--where DateCreate<=@dateReg and ReportMonth>=@monthMin and ReportMonth<=@monthMax and ReportYear=@year
--group by CodeM,unitCode

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
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode
--вставил т.к. требуется вывод все данных даже если нету принятых случаев с данными единицами учета					
insert @tPlan(tfomsCode,unitCode,Vkm,Vdm) 
select t.tfomsCode,t.unitCode,t.Vkm,t.Vdm
from @tPlan p right join (
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
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode
where p.tfomsCode is null

update @tPlan
set V=t.V
from @tPlan p inner join (						
							select left(mo.tfomsCode,6) as tfomsCode,SUM(pl.rate) as V,pu.unitCode
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
										and pl.rf_QuarterId=@Quarter
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId										
							group by mo.tfomsCode,pu.unitCode
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode


insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Vkm,Spred)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vkm,0),isnull(p.Vdm,0),Vkm,Spred
from @tPlan p

--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
--------------------------------------------------------------------------------------
select distinct QuarterName+' '+cast(@year as CHAR(4))+' г.'  as ReportDate from @t where QuarterID=@Quarter	
	
select  v.CodeM
		,v.NameS as LPU
		,u.unitName
		,p.Vm - isnull(p.Vkm,0) as Utv
		,isnull(p.Vkm,0)
		,p.Vdm as MEK		
		,p.Spred
		,p.Spred-p.Vdm as DiffMek
		,p.Spred-(p.Vdm+p.Vm) as Diff		
		,cast((100*cast((p.Spred-p.Vdm) as decimal(15,2))/(case when p.Vdm+p.Vm=0 then 1 else cast((p.Vdm+p.Vm) as decimal(15,2))end)) as decimal(11,2)) as [Percent]
		
from (
		select top 100 percent CodeLPU,UnitCode,cast(sum(Vm) as decimal(11,2)) as Vm,cast(sum(Vdm) as decimal(11,2)) as Vdm,cast(sum(Vkm) as money) as Vkm
				,isnull(sum(Spred),0)  as Spred
		from @plan1 
		group by CodeLPU,UnitCode
		order by CodeLPU,UnitCode
	 ) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode
		 inner join oms_nsi.dbo.vw_sprT001 v on
			p.CodeLPU=v.CodeM	
--where p.Vm - isnull(p.Vkm,0)>0
order by CodeM
go
