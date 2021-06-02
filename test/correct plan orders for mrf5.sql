use RegisterCases
go
select count(*) from List_PlanOrders
--select *
--into t_PlanOrders2011_20111213
--from t_PlanOrders2011


--delete from t_PlanOrders2011 
--where CodeLPU in (select left(cast(p1.CodeLPU as CHAR(8)),6) from List_PlanOrders p1 group by left(cast(p1.CodeLPU as CHAR(8)),6) )
insert t_PlanOrders2011(CodeLPU,MonthRate,YearRate,unitCode,Rate)
select left(cast(p1.CodeLPU as CHAR(8)),6),[Month],[Year],UNIT,Rate
from List_PlanOrders p1
			
			