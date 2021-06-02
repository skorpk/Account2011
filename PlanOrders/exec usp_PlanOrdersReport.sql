USE RegisterCases
GO
DECLARE @idFile INT,
		@idFileBack int
SELECT @idFile=rf_idFiles, @idFileBack=idFileBack FROM dbo.vw_getFileBack WHERE DateCreate>'20180207' AND AmountCasesPayed>1000 ORDER BY NEWID()

EXEC dbo.usp_PlanOrdersReport_test @idFile,@idFileBack 

