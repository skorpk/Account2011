USE RegisterCases
GO
IF OBJECT_ID('usp_GetRegisterCasesXSD',N'P') IS NOT NULL
DROP PROC usp_GetRegisterCasesXSD
GO
CREATE PROCEDURE usp_GetRegisterCasesXSD		
				@fileName VARCHAR(60)
AS
SELECT xsdDate FROM dbo.t_XSD WHERE FileNameXSD=@fileName
GO