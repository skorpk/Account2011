use RegisterCases

declare @tEmpty as table(rf_idFiles int,FileNameHR varchar(30))

insert @tEmpty
select rf_idFiles,ltrim(f.FileNameHR)
from t_RefCasePatientDefine ref inner join t_File f on
		ref.rf_idFiles=f.id
								left join PolicyRegister.dbo.ZP1LOG z on
		ltrim(f.FileNameHR)= substring(ltrim(filename),2,LEN(filename)-1)
where ref.IsUnloadIntoSP_TK is null and f.DateRegistration<'20120225' and z.ID is null
group by rf_idFiles,f.FileNameHR,z.FILENAME
----------------------------------------------------
declare @idRecordCaseNext as TVP_CasePatient
declare cRunProcedure cursor for
		select rf_idFiles,FileNameHR from @tEmpty
		
		declare @fileName varchar(30),@id int
	open cRunProcedure
	fetch next from cRunProcedure into @id,@fileName
	while @@FETCH_STATUS = 0
	begin		
					
		insert @idRecordCaseNext
		select rf_idCase,rf_idRegisterPatient
		from t_RefCasePatientDefine where rf_idFiles=@id and IsUnloadIntoSP_TK is null

		--select * from @idRecordCaseNext

		exec usp_DefineSMOIteration2_4 @idRecordCaseNext,2,@fileName
		delete @idRecordCaseNext
fetch next from cRunProcedure into @id,@fileName
	end
	close cRunProcedure
	deallocate cRunProcedure