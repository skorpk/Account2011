USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprV019]'))
DROP VIEW dbo.vw_sprV019
GO
CREATE VIEW vw_sprV019
AS 
SELECT v19.Code AS IDHM,v19.NAME,m.DiagnosisCode,v18.Code AS IDHVID
FROM OMS_NSI.dbo.sprV019 v19 INNER JOIN OMS_NSI.dbo.sprV019MKB m ON
			v19.SprV019Id=m.rf_sprV019Id
							INNER JOIN OMS_NSI.dbo.sprV018 v18 ON
			v19.rf_sprV018Id=v18.SprV018Id
GO			