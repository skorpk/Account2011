USE RegisterCases
GO
USE RegisterCases
GO
IF OBJECT_ID('vw_IsSpecialCase',N'V') IS NOT NULL
DROP VIEW vw_IsSpecialCase
GO
CREATE VIEW vw_IsSpecialCase
AS
SELECT OS_SLUCH,IsClinincalExamination,Step FROM oms_nsi.dbo.sprSpecialCase
GO