USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_ErrorsDescription]    Script Date: 14.08.2020 9:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_ErrorsDescription]
AS
SELECT TOP 100 PERCENT CAST(Code AS VARCHAR(12)) AS Code,DescriptionError,DateBeg,Reason 
FROM OMS_NSI.dbo.sprAllErrors
UNION ALL 
SELECT TOP 100 PERCENT ID_TEST AS Code,FieldName+' - '+(CASE WHEN LEN(COMMENT)=0 THEN 'не правильное значение' ELSE COMMENT END ) ,DATEBEG,'' FROM sprQ015
ORDER BY Code
GO


