USE RegisterCases
GO
select DISTINCT fb.rf_idFiles,fb.id
from t_FileBack fb inner join t_RegisterCaseBack rcb on
				fb.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
						INNER JOIN AccountOMS.dbo.t_File ff ON
            fb.CodeM=ff.CodeM
						INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
            ff.id=a.rf_idFiles
where fb.DateCreate>'20200128' AND fb.IsUnload=1 AND rcb.PropertyNumberRegister=2 

BEGIN TRANSACTION
	UPDATE fb SET fb.IsUnload=0
	from t_FileBack fb inner join t_RegisterCaseBack rcb on
					fb.id=rcb.rf_idFilesBack
						inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
								inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id								
	where fb.DateCreate>'20200128' AND fb.IsUnload=1 AND rcb.PropertyNumberRegister=2

commit