USE [RegisterCases]
GO

/****** Object:  View [dbo].[VW_sprCoefficient]    Script Date: 26.01.2017 14:31:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[VW_sprCoefficient]
as
SELECT L.code,L.name,CAST(LC.coefficient AS DECIMAL(3,2)) AS coefficient,LC.dateBeg,LC.dateEnd
FROM OMS_NSI.DBO.tSLP L INNER JOIN OMS_NSI.dbo.tSLPCoefficient LC ON
			L.SLPId=LC.rf_SLPId
where LC.flag = 'A'
GO 