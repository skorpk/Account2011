USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprMUUnionV001]    Script Date: 04.01.2019 9:03:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vw_sprMUUnionV001]
AS 
SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=55 AND MUUnGroupCode=1
UNION ALL
SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=3
UNION ALL
SELECT IDRB FROM OMS_NSI.dbo.V001

GO


