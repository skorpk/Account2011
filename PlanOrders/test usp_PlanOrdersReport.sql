USE RegisterCases
GO
SET ARITHABORT OFF
go
DECLARE @idFile int, 
		@idFileBack int
 
SELECT @idFile=rf_idFiles, @idFileBack=idFileBack
FROM dbo.vw_getFileBack WHERE CodeM='125901' AND ReportYear=2018 AND NumberRegister=137 AND PropertyNumberRegister=1

 EXEC dbo.usp_PlanOrdersReport @idFile,@idFileBack