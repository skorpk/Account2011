USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprNomenclMUBodyParts]    Script Date: 23.12.2019 10:49:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_sprNomenclMUBodyParts] 
AS
SELECT p.codeNomenclMU,b.code,p.dateBeg,p.dateEnd
FROM oms_nsi.dbo.sprNomenclMUBodyParts p INNER JOIN oms_nsi.dbo.sprBodyParts b ON
			p.rf_sprBodyPartsId=b.sprBodyPartsId
GO


