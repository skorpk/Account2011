SET QUOTED_IDENTIFIER ON

declare @idFile int
declare exec_cursor cursor for 
		select distinct f.id
		from vw_getIdFileNumber f inner join t_RefCasePatientDefine d on
				f.id=d.rf_idFiles
				and f.ReportYear=2012 and f.DateRegistration<DATEADD(DD,-4, GETDATE())
				and d.IsUnloadIntoSP_TK is null
								inner join t_CaseDefineZP1 z on
				d.id=z.rf_idRefCaseIteration
				and z.DateOperationt<DATEADD(DD,-4, GETDATE())
								inner join PolicyRegister.dbo.ZP1 zp1 on
				z.rf_idZP1=zp1.id
		where zp1.REPL is null
open exec_cursor
fetch next from exec_cursor into @idFile
while @@fetch_status=0
begin
	exec usp_DefineSMOIteration2_4Repeat @idFile
	fetch next from exec_cursor into @idFile
end
close exec_cursor
deallocate exec_cursor

