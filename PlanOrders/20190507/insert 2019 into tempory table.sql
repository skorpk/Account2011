USE RegisterCases
GO

TRUNCATE TABLE tmp_PlanOrdersReport

declare @idFile INT,@idFileBack int
declare exec_cursor cursor for SELECT v.rf_idFiles,idFileBack
								FROM dbo.t_FileBack	t INNER JOIN dbo.vw_getFileBack v ON
										t.id=v.idFileBack
								WHERE v.ReportYear=2019 AND v.CodeM='141023'
								ORDER BY t.id desc
open exec_cursor
fetch next from exec_cursor into @idFile,@idFileBack
while @@fetch_status=0
begin
	INSERT dbo.tmp_PlanOrdersReport
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

