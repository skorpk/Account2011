use RegisterCases
go
if OBJECT_ID('usp_IsDefineSMOIteration2_4Repeat',N'P') is not null
	drop proc usp_IsDefineSMOIteration2_4Repeat
GO
CREATE PROCEDURE usp_IsDefineSMOIteration2_4Repeat
(
				@id int
)
AS
IF EXISTS(SELECT * FROM dbo.vw_getFileBack WHERE rf_idFiles=@id AND PropertyNumberRegister IN(2,0))
	SELECT 1
ELSE 
	SELECT 0
GO