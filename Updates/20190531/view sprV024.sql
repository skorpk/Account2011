USE RegisterCases
GO
CREATE VIEW sprV024
as
SELECT  IDDKK ,DKKNAME ,DATEBEG ,DATEEND FROM oms_nsi.dbo.sprV024 
UNION ALL
SELECT  IDDKK ,DKKNAME ,DATEBEG ,DATEEND FROM oms_nsi.dbo.Life_sprV024
go