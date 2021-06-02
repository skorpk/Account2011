USE RegisterCases
GO
SET QUOTED_IDENTIFIER ON
declare @idFile INT,@idFileBack int
declare exec_cursor cursor for 
								SELECT rf_idFiles,t.id AS idFileBack 
								FROM dbo.t_FileBack t INNER JOIN dbo.vw_getIdFileNumber v  ON
											t.rf_idFiles=v.id                              
								WHERE v.ReportYear=2018 AND v.CodeM='165531' AND v.ReportMonth<4 --and NOT EXISTS(SELECT 1 FROM dbo.t_PlanOrdersReport WHERE rf_idFileBack=t.id)
								ORDER BY t.DateCreate
								
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
--EXEC usp_GetPlanOrders  @idFile=134953,@idFileBack=228065	