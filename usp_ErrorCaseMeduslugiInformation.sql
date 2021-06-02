use RegisterCases
go
if OBJECT_ID('usp_ErrorCaseMeduslugiInformation',N'P') is not null
drop proc usp_ErrorCaseMeduslugiInformation
go
create proc usp_ErrorCaseMeduslugiInformation
			@idCase BIGINT
AS
SELECT CAST(id AS BIGINT) AS id, GUID_MU, rf_idV002 AS Profil, DateHelpBegin, DateHelpEnd, DiagnosisCode, MUCode, Quantity, Price, TotalPrice,
		 rf_idV004 AS PRVS,MUSurgery
FROM dbo.t_Meduslugi 
WHERE rf_idCase=@idCase
ORDER BY id
GO