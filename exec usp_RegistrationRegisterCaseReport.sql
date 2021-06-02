USE RegisterCases
GO
DECLARE @idFile INT,
		   @idFileBack int
SELECT @idFile=rf_idFiles, @idFileBack=idFileBack FROM dbo.vw_getFileBack WHERE ReportYear=2017 AND CodeM='255315' AND NumberRegister=1474
SELECT @idFile, @idFileBack

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

EXEC dbo.usp_RegistrationRegisterCaseReport @idFile ,   @idFileBack 


