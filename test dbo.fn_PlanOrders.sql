--select * from t_Case
declare @codeLPU char(6)='111008',
		@month tinyint=11,
		@year smallint=2011
select * from vw_sprT001 where CodeM=@codeLPU
select *
from dbo.fn_PlanOrders(@codeLPU,@month,@year)
