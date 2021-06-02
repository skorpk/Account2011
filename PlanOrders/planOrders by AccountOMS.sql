use AccountOMS
go

declare @month tinyint=12,
		@year smallint=2011
		
select l.CodeM,l.NameS,p.unitName,p.Vdm,p.Vm,p.Spred,p.Spred-(p.Vdm+p.Vm) as Diff
from (select t.CodeM,t.NameS 
	  from vw_sprT001 t inner join t_File f on
				t.CodeM=f.CodeM
	  group by t.CodeM,t.NameS 
	) l cross apply 
			(select p.*,u.unitName 
			 from dbo.fn_PlanOrders(l.CodeM,@month,@year) p inner join RegisterCases.dbo.vw_sprUnit u on p.UnitCode=u.unitCode
			 ) p  
