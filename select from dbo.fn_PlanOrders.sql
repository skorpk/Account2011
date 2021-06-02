declare @month tinyint=10,
		@year smallint=2011,
		@codeLPU int='124528'
select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)

