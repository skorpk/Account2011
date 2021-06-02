--SET STATISTICS IO ON
--SET STATISTICS TIME ON
--go
--declare @month tinyint=10,
--		@year smallint=2011,
--		@codeLPU int=12452812
--select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)
--go
--SET STATISTICS IO OFF
--SET STATISTICS TIME OFF

declare @month tinyint=11,
		@year smallint=2011,
		@codeLPU int=16100716

declare @t as table(MonthID tinyint,QuarterID tinyint,partitionQuarterID tinyint)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				

select mo.tfomsCode,SUM(pl.rate) as V,pu.unitCode,t.QuarterID
from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
					py.rf_MOId=mo.MOId and
					py.[year]=@year
						inner join oms_NSI.dbo.tPlan pl on
					py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
						inner join oms_NSI.dbo.tPlanUnit pu on
					pl.rf_PlanUnitId=pu.PlanUnitId
						inner join @t t on
					pl.rf_QuarterId<t.QuarterID				
where tfomsCode=@codeLPU and t.MonthID=@month
group by mo.tfomsCode,pu.unitCode,t.QuarterID

select mo.tfomsCode,pu.unitCode,t.partitionQuarterID*SUM(pl.rate)/3 as Vt,
			SUM(pl.rate)-3*cast(SUM(pl.rate)/3 as int) as O,
			t.partitionQuarterID,SUM(pl.rate)
from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
				py.rf_MOId=mo.MOId and
				py.[year]=@year
							inner join oms_NSI.dbo.tPlan pl on
				py.PlanYearId=pl.rf_PlanYearId and 
				pl.flag='A'
							inner join oms_NSI.dbo.tPlanUnit pu on
				pl.rf_PlanUnitId=pu.PlanUnitId				
							inner join @t t on
				pl.rf_QuarterId=t.QuarterID and t.MonthID=@month
where tfomsCode=@codeLPU 
group by mo.tfomsCode,pu.unitCode,t.partitionQuarterID

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
					pl.PlanId=pc.rf_PlanId and pc.rf_MonthId<=@month
where tfomsCode=@codeLPU 
group by mo.tfomsCode,pu.unitCode


 --select t1.tfomsCode,t1.unitCode,t1.V+isnull(t2.Vt,0)+isnull(t2.O,0)+isnull(t3.Vkm,0),isnull(t3.Vdm,0),t1.V,t2.Vt,t2.O,t3.Vkm
	--from (
	--	select mo.tfomsCode,SUM(pl.rate) as V,pu.unitCode
	--	from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
	--				py.rf_MOId=mo.MOId and
	--				py.[year]=@year
	--					inner join oms_NSI.dbo.tPlan pl on
	--				py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
	--					inner join oms_NSI.dbo.tPlanUnit pu on
	--				pl.rf_PlanUnitId=pu.PlanUnitId
	--					inner join @t t on
	--				pl.rf_QuarterId<t.QuarterID				
	--	where tfomsCode=@codeLPU and t.MonthID=@month
	--	group by mo.tfomsCode,pu.unitCode
	--	) t1 left join (
	--						select mo.tfomsCode,pu.unitCode,(t.partitionQuarterID*SUM(pl.rate)/3) as Vt,SUM(pl.rate)-3*cast(SUM(pl.rate)/3 as int) as O
	--						from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
	--									py.rf_MOId=mo.MOId and
	--									py.[year]=@year
	--										inner join oms_NSI.dbo.tPlan pl on
	--									py.PlanYearId=pl.rf_PlanYearId and 
	--									pl.flag='A'
	--										inner join oms_NSI.dbo.tPlanUnit pu on
	--									pl.rf_PlanUnitId=pu.PlanUnitId				
	--										inner join @t t on
	--									pl.rf_QuarterId=t.QuarterID
	--						where tfomsCode=@codeLPU and t.MonthID=@month
	--						group by mo.tfomsCode,pu.unitCode,t.partitionQuarterID
	--						) t2 on
	--	t1.tfomsCode=t2.tfomsCode and
	--	t1.unitCode=t2.unitCode
	--		left join (
	--					select mo.tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
	--							sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
	--					from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
	--								py.rf_MOId=mo.MOId and
	--								py.[year]=@year
	--									inner join oms_NSI.dbo.tPlan pl on
	--								py.PlanYearId=pl.rf_PlanYearId and 
	--								pl.flag='A'
	--									inner join oms_NSI.dbo.tPlanUnit pu on
	--								pl.rf_PlanUnitId=pu.PlanUnitId
	--									left join oms_NSI.dbo.tPlanCorrection pc on
	--								pl.PlanId=pc.rf_PlanId and pc.rf_MonthId<=@month
	--					where tfomsCode=@codeLPU 
	--					group by mo.tfomsCode,pu.unitCode
	--					) t3 on
	--	t1.tfomsCode=t3.tfomsCode and
	--	t1.unitCode=t3.unitCode