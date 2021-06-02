
--select * from t_PlanOrders2011 where CodeLPU='145526'
--select * from t_RegistersCase

--select *
--from vw_sprMUCompletedCase

--select *
--from vw_sprMU
declare @codeLPU char(6)='171004'
		,@month tinyint=10
		,@year smallint=2011
		
declare @ts as table(rf_idCase bigint)

insert @ts
select rf_idCase--,MUCode--64
from vw_sprMU vwC inner join (
								select m.*
								from t_CaseDefine c inner join t_RefCasePatientDefine cd on
										c.rf_idRefCaseIteration=cd.id
													inner join t_Meduslugi m on
										cd.rf_idCase=m.rf_idCase																		
							) t on vwc.MU=t.MUCode
--where vwC.MU is null
declare @t1 as table(rf_idCase bigint,Quantity bigint,unitCode int,TotalRest int)

insert @t1(rf_idCase,Quantity,unitCode)
select rf_idCase,SUM(Quantity),unitCode
from (
		select top 1000000 m.rf_idCase,m.id,m.Quantity,t1.unitCode
				from @ts c1 inner join t_Meduslugi m on
					c1.rf_idCase=m.rf_idCase							
							inner join dbo.vw_sprMU t1 on
							m.MUCode=t1.MU	
		order by m.id
		) t
group by rf_idCase,unitCode
select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)

declare @ost int

declare cPlan cursor for
	select f.UnitCode,f.Vdm,f.Vm,f.Spred
	from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	declare @unit int,@vdm int, @vm int, @spred int
open cPlan
fetch next from cPlan into @unit,@vdm,@vm,@spred
while @@FETCH_STATUS = 0
begin		
	--select @ost=@vm+@vdm-ISNULL(Quantity, 0)-@spred from @t1
	--select @ost	
	declare cCase cursor for
		select t.rf_idCase,t.Quantity from @t1 t where unitCode=@unit
		declare @idCase bigint, @Quantity int
	open cCase
	fetch next from cCase into @idCase,@Quantity
	while @@FETCH_STATUS=0
	begin	
		
		--select @idCase,@vm+@vdm-@Quantity-@spred
		update @t1 set TotalRest=@vm+@vdm-@Quantity-@spred where rf_idCase=@idCase
		set @spred=@spred+@Quantity
		
		fetch next from cCase into @idCase,@Quantity
	end
	close cCase
	deallocate cCase
	
	--update @t1 set @vm=Totalrest=@vm+@vdm-ISNULL(Quantity, 0) where unitCode=@unit
	fetch next from cPlan into @unit,@vdm,@vm,@spred
end
close cPlan
deallocate cPlan

select * from @t1
