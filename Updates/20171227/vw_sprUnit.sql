USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprUnit]    Script Date: 27.12.2017 14:43:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter view [dbo].[vw_sprUnit]
as
select unitCode,unitName,calculationType
from oms_nsi.dbo.tPlanUnit

GO


