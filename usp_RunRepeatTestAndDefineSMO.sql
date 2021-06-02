USE RegisterCases
GO

/****** Object:  StoredProcedure dbo.usp_RunRepeatTestAndDefineSMO    Script Date: 12/24/2012 10:00:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.usp_RunRepeatTestAndDefineSMO') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.usp_RunRepeatTestAndDefineSMO
GO

create procedure dbo.usp_RunRepeatTestAndDefineSMO
				@idFile int
as
if NOT EXISTS(select * from t_FileBack where rf_idFiles=@idFile)
begin
	if exists(select * from t_ErrorProcessControl where rf_idFile=@idFile)
	begin 
		delete from t_ErrorProcessControl where rf_idFile=@idFile
	end
	if exists(select * from t_RefCasePatientDefine where rf_idFiles=@idFile)
	begin
		delete from t_RefCasePatientDefine where rf_idFiles=@idFile
	end

	exec usp_RunTestsDefineSMOCreateSPTK @idFile
	
end
else
begin
	select 'Реестр СП и ТК был сформирован'
end

GO


