--select rf_idFiles
--from t_RefCasePatientDefine
--group by rf_idFiles
--delete from t_RefCasePatientDefine where rf_idFiles=10

select *
from t_RefCasePatientDefine r inner join t_CaseDefine cd on
		r.id=cd.rf_idRefCaseIteration
where r.rf_idFiles=14