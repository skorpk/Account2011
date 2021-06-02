USE RegisterCases
GO
ALTER VIEW vw_sprAddCriterion
as
SELECT code FROM oms_nsi.dbo.sprArtificialVentilation
UNION ALL
SELECT schemeCode FROM oms_nsi.dbo.sprDrugTherapyScheme
UNION ALL
SELECT code	FROM oms_nsi.dbo.sprPatientCondition
go
GRANT SELECT ON vw_sprAddCriterion TO db_RegisterCase