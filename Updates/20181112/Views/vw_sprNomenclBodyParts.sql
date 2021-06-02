USE RegisterCases
GO
if OBJECT_ID('vw_sprNomenclBodyParts',N'V') is not NULL
	DROP VIEW vw_sprNomenclBodyParts
GO
CREATE VIEW vw_sprNomenclBodyParts
AS
SELECT s.codeNomenclMU,p.code
FROM oms_nsi.dbo.sprNomenclMUBodyParts s INNER JOIN oms_nsi.dbo.sprBodyParts p ON
			s.rf_sprBodyPartsId=p.sprBodyPartsId
GO
GRANT SELECT ON  vw_sprNomenclBodyParts TO db_RegisterCase