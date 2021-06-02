use RegisterCases
go
select 'exec usp_FillBackTablesAfterAllIteration '+CAST(t1.rf_idFiles as varchar(10))
from(
		select COUNT(distinct id) as TotalRow,rf_idFiles
		from t_RefCasePatientDefine 		
		where IsUnloadIntoSP_TK is null
		group by rf_idFiles
	) t1 inner join (
						select COUNT(distinct r.id) as DefineRow,rf_idFiles
						from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
								r.id=i.rf_idRefCaseIteration
								and i.rf_idIteration in (2,3,4)
						where IsUnloadIntoSP_TK is null
						group by rf_idFiles	
					) t2 on 
			t1.rf_idFiles=t2.rf_idFiles
			and t1.TotalRow=t2.DefineRow
order by 'exec usp_FillBackTablesAfterAllIteration '+CAST(t1.rf_idFiles as varchar(10))