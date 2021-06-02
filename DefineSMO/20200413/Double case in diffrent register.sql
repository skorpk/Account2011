USE RegisterCases
GO
DECLARE	@idFile INT=184414,
		@idFileBack INT=306497

SELECT rc.rf_idRecordCase
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack							
					inner join dbo.t_CaseBack cb ON
        rc.id=cb.rf_idRecordCaseBack
where f.rf_idFiles=@idFile 
GROUP BY rc.rf_idRecordCase
HAVING COUNT(*)>1

--;WITH cte
--AS(
--select rc.rf_idRecordCase,r.PropertyNumberRegister, ROW_NUMBER() OVER(PARTITION BY rc.rf_idRecordCase ORDER BY r.PropertyNumberRegister) AS idRow
--from t_FileBack f inner join t_RegisterCaseBack r on
--		f.id=r.rf_idFilesBack
--					inner join t_RecordCaseBack rc on
--		r.id=rc.rf_idRegisterCaseBack							
--					inner join dbo.t_CaseBack cb ON
--        rc.id=cb.rf_idRecordCaseBack
--where f.rf_idFiles=@idFile 
--)
--SELECT *
--FROM cte WHERE cte.idRow>1
--ORDER BY cte.rf_idRecordCase

SELECT DISTINCT rc.rf_idRecordCase,r.PropertyNumberRegister
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack							
					inner join dbo.t_CaseBack cb ON
        rc.id=cb.rf_idRecordCaseBack
where f.rf_idFiles=@idFile AND rc.rf_idRecordCase IN(125532796,125532797,125533066,125533241,125533484,125534379,125535020,125535021,125535535,125535867)
ORDER BY rc.rf_idRecordCase,r.PropertyNumberRegister