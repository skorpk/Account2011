use RegisterCases
go
declare @codeLPU varchar(6)='106001'
		,@month tinyint=1,
		@year smallint=2012
		
select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)

set @month=@month+3
select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)

set @month=@month+3
select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)

set @month=@month+3
select * from dbo.fn_PlanOrders(@codeLPU,@month,@year)