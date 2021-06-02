USE RegisterCases
GO
declare @idFile INT,@idFileBack int
declare exec_cursor cursor for SELECT v.rf_idFiles,idFileBack
								FROM (
										SELECT id FROM dbo.t_FileBack
										except
										SELECT DISTINCT rf_idFileBack FROM dbo.t_PlanOrdersReport
									) t INNER JOIN dbo.vw_getFileBack v ON
										t.id=v.idFileBack
								WHERE v.ReportYear>2012
								ORDER BY t.id desc
open exec_cursor
fetch next from exec_cursor into @idFile,@idFileBack
while @@fetch_status=0
begin
	INSERT dbo.t_PlanOrdersReport
			( rf_idFile ,
			  rf_idFileBack ,
			  CodeLPU ,
			  UnitCode ,
			  Vm ,
			  Vdm ,
			  Spred ,
			  MonthReport ,
			  YearReport
			) EXEC usp_GetPlanOrders @idFile,@idFileBack
	fetch next from exec_cursor into @idFile,@idFileBack
end
close exec_cursor
deallocate exec_cursor
GO

