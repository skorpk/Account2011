use RegisterCases
go

declare cIteration cursor for
	select rf_idFiles,FileNameHR from vw_GetUnLoadPersonInPolicyDB
	declare @fileName varchar(30),
			@idFile int
open cIteration
fetch next from cIteration into @idFile,@fileName
while @@FETCH_STATUS = 0
begin		
	-------------------------------------------------------
	exec usp_DefineSMOIteration2_4Repeat @idFile
	-------------------------------------------------------
	fetch next from cIteration into @idFile,@fileName
end
close cIteration
deallocate cIteration