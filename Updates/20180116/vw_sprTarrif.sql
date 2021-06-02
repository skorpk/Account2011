USE RegisterCases
GO
CREATE VIEW vw_sprTarrif
as
SELECT MU,CAST(LevelType AS VARCHAR(10)) AS LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,CAST(Price AS DECIMAL(11,2)) AS Price FROM vw_sprCompletedCaseMUTariff 
UNION ALL 
SELECT MU,CAST(LevelType AS VARCHAR(10)) AS LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,CAST(Price AS DECIMAL(11,2)) FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff
UNION ALL
SELECT  CODE_PRICE ,LEVEL_PAY ,AGE,DATE_B ,DATE_E ,CAST(Price AS DECIMAL(11,2))  FROM oms_nsi.dbo.PriceST