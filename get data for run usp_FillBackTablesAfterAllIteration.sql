--EXEC sp_whoIsActive
USE RegisterCases
GO
SELECT 'exec usp_FillBackTablesAfterAllIteration @idFile='+CAST(t1.rf_idFiles AS VARCHAR(7)) +';',t1.rf_idFiles,'('+CAST(t1.rf_idFiles AS VARCHAR(7))+'),'
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
order by rf_idFiles

/*
BEGIN TRANSACTION
DELETE FROM dbo.t_FileBack WHERE id IN (53954,53987,53988)
SELECT @@ROWCOUNT


update t_RefCasePatientDefine 
set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
					r.id=i.rf_idRefCaseIteration
where rf_idFiles =@idFile and i.rf_idIteration<>1

COMMIT


*/