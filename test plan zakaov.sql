
declare @month tinyint=11,
		@year smallint=2011,
		@codeLPU varchar(6)='124528'
		
declare @t1 as table(rf_idCase bigint,Quantity bigint,unitCode int,TotalRest int)

insert @t1(rf_idCase,Quantity,unitCode) values(1,15,2),(1,156,3),(2,1600,2),
												(2,1000,3),(3,300,3),(5,5000,2)
select * 
from @t1
order by unitCode
		
declare cPlan cursor for
	select f.UnitCode,f.Vdm,f.Vm
	from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	declare @unit int,@vdm int, @vm int
open cPlan
fetch next from cPlan into @unit,@vdm,@vm
while @@FETCH_STATUS = 0
begin		
	--select @unit,@vdm,@vm
	update @t1 set @vm= Totalrest=@vm+@vdm-ISNULL(Quantity, 0) where unitCode=@unit
	fetch next from cPlan into @unit,@vdm,@vm
end
close cPlan
deallocate cPlan

select * 
from @t1
where TotalRest>=0
order by unitCode