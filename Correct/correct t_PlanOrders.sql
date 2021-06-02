update t_PlanOrdersReport set CodeLPU=t.CodeM
from t_PlanOrdersReport p inner join (
		select f.id,rf_idFileBack,f.FileNameHR,SUBSTRING(f.FileNameHR,4,6) as CodeM
		from t_PlanOrdersReport p inner join t_File f on
				p.rf_idFile=f.id
		group by f.id,f.FileNameHR,rf_idFileBack
	) t on 
	p.rf_idFile=t.id
	and p.rf_idFileBack=t.rf_idFileBack