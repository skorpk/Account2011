USE RegisterCases
GO

select t1.rf_idFiles
--INTO #tFile
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

exec usp_FillBackTablesAfterAllIteration @idFile=127190

/*
SELECT DISTINCT  z.*,e.ErrorNumber,e.DateRegistration
FROM dbo.t_RefCasePatientDefine r inner JOIN dbo.t_CasePatientDefineIteration i ON
				r.id=i.rf_idRefCaseIteration
								INNER JOIN #tFile ff ON
				r.rf_idFiles=ff.rf_idFiles                              
								inner JOIN dbo.t_CaseDefineZP1Found z ON
				r.id=z.rf_idRefCaseIteration                              
								INNER JOIN dbo.t_ErrorProcessControl e ON
				r.rf_idCase=e.rf_idCase 
WHERE OGRN_SMO IS NOT NULL AND e.ErrorNumber=57				                             

BEGIN TRANSACTION
DELETE FROM dbo.t_ErrorProcessControl
FROM dbo.t_RefCasePatientDefine r inner JOIN dbo.t_CasePatientDefineIteration i ON
				r.id=i.rf_idRefCaseIteration
								INNER JOIN #tFile ff ON
				r.rf_idFiles=ff.rf_idFiles                              
								inner JOIN dbo.t_CaseDefineZP1Found z ON
				r.id=z.rf_idRefCaseIteration                              
								INNER JOIN dbo.t_ErrorProcessControl e ON
				r.rf_idCase=e.rf_idCase 
WHERE OGRN_SMO IS NOT NULL AND e.ErrorNumber=57	

SELECT DISTINCT z.*
FROM dbo.t_RefCasePatientDefine r inner JOIN dbo.t_CasePatientDefineIteration i ON
				r.id=i.rf_idRefCaseIteration
								INNER JOIN #tFile ff ON
				r.rf_idFiles=ff.rf_idFiles                              
								inner JOIN dbo.t_CaseDefineZP1Found z ON
				r.id=z.rf_idRefCaseIteration                              					
WHERE OGRN_SMO IS NOT NULL 

commit
  */

 GO
DROP TABLE #tFile  