use RegisterCases
go
declare @id_file int=6,
		@file varchar(26)
select @file=FileNameHR from t_File where id=@id_file

declare @idTable as TVP_CasePatient
insert @idTable
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where rf_idFiles=@id_file and IsUnloadIntoSP_TK is null

select @file,* from @idTable

exec usp_DefineSMOIteration2_4 @idTable,2,@file
go

--declare @id_file int=4,
--		@file varchar(26)
--select @file=FileNameHR from t_File where id=@id_file

--declare @idTable as TVP_CasePatient
--insert @idTable
--select rf_idCase,rf_idRegisterPatient
--from t_RefCasePatientDefine
--where rf_idFiles=@id_file and IsUnloadIntoSP_TK is null

--select @file

--exec usp_DefineSMOIteration2_4 @idTable,2,@file
--go
--declare @id_file int=5,
--		@file varchar(26)
--select @file=FileNameHR from t_File where id=@id_file

--declare @idTable as TVP_CasePatient
--insert @idTable
--select rf_idCase,rf_idRegisterPatient
--from t_RefCasePatientDefine
--where rf_idFiles=@id_file and IsUnloadIntoSP_TK is null

--select @file

--exec usp_DefineSMOIteration2_4 @idTable,2,@file
--go
--declare @id_file int=6,
--		@file varchar(26)
--select @file=FileNameHR from t_File where id=@id_file

--declare @idTable as TVP_CasePatient
--insert @idTable
--select rf_idCase,rf_idRegisterPatient
--from t_RefCasePatientDefine
--where rf_idFiles=@id_file and IsUnloadIntoSP_TK is null

--select @file

--exec usp_DefineSMOIteration2_4 @idTable,2,@file
--go












