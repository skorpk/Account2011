USE RegisterCases
go
CREATE VIEW vw_sprNomenclMUBodyParts 
as
SELECT p.codeNomenclMU,b.code
FROM oms_nsi.dbo.sprNomenclMUBodyParts p INNER JOIN oms_nsi.dbo.sprBodyParts b ON
			p.rf_sprBodyPartsId=b.sprBodyPartsId
GO
GRANT SELECT ON vw_sprNomenclMUBodyParts TO db_RegisterCase