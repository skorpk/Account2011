USE RegisterCases
GO
DECLARE @idFile INT,
		@idFileBack INT
SELECT @idFile=rf_idFiles,@idFileBack=idFileBack FROM dbo.vw_getFileBack WHERE DateCreate>'20180116' AND AmountCasesPayed>100 ORDER BY NEWID()

SELECT * FROM dbo.vw_getFileBack WHERE idFileBack=@idFileBack
SET STATISTICS TIME,IO ON 
EXEC usp_PlanOrdersReport_Test @idFile,@idFileBack
SET STATISTICS TIME,IO OFF
--EXEC usp_PlanOrdersReport @idFile,@idFileBack

--SELECT *
--FROM dbo.t_PlanOrdersReport WHERE rf_idFileBack=@idFileBack	AND rf_idFile=@idFile AND TotalVm>0