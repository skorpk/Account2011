USE RegisterCases
go
ALTER VIEW vw_sprNomenclBodyParts
AS
SELECT s.codeNomenclMU,p.code, s.dateBeg,s.dateEnd
FROM oms_nsi.dbo.sprNomenclMUBodyParts s INNER JOIN oms_nsi.dbo.sprBodyParts p ON
			s.rf_sprBodyPartsId=p.sprBodyPartsId