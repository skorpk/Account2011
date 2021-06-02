use RegisterCases
go
declare @codeLPU as table (CodeM varchar(6))
insert @codeLPU
select f.CodeM
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
group by f.CodeM


select t.CodeLPU,t1.NameS,t.UnitCode,u.unitName,t.Vm,t.Vdm,t.Spred,t.Diffrence 
from (
		select p.CodeLPU,p.UnitCode,p.Spred,p.Vm,p.Vdm,(p.Spred-p.Vm-p.Vdm) as Diffrence
		from @codeLPU l cross apply dbo.fn_PlanOrders(l.CodeM,12,2011) p 
   	  ) t inner join vw_sprUnit u on
   	  t.UnitCode=u.unitCode
   			inner join vw_sprT001 t1 on
   		t.CodeLPU=t1.CodeM
--where t.Diffrence>0
order by 1,2