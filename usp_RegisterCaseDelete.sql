use RegisterCases
go
if OBJECT_ID('usp_RegisterCaseDelete',N'P') is not null
drop proc usp_RegisterCaseDelete
go
create procedure usp_RegisterCaseDelete
				@idFile int
as
declare @codeM char(6),
		@numRegister int,
		@year smallint

select @codeM=CodeM, @numRegister=a.NumberRegister, @year=a.ReportYear
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
where f.id=@idFile		

if NOT EXISTS(select * from AccountOMS.dbo.vw_getIdFileNumber where CodeM=@codeM and NumberRegister=@numRegister and ReportYear=@year)
begin
	begin transaction
	begin try
		delete from t_FileBack where rf_idFiles=@idFile
		delete from t_RefCasePatientDefine where rf_idFiles=@idFile
		delete from t_ErrorProcessControl where rf_idFile=@idFile
		delete from t_File where id=@idFile
	end try
	begin catch
	if @@TRANCOUNT>0
		select 'Ошибка при снятии реестра сведений '+ERROR_MESSAGE()
		rollback transaction
	end catch
	if @@TRANCOUNT>0
		select 'Реестр снят с регисрации'
		commit transaction
end
else 
begin 
	select 'Реестр сведений невозможно снять т.к. по нему выставленны счета.'
end
go