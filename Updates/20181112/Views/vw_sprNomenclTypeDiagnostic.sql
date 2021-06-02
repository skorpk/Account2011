USE RegisterCases
GO
if OBJECT_ID('vw_sprNomenclTypeDiagnostic',N'V') is not NULL
	DROP VIEW vw_sprNomenclTypeDiagnostic
GO
CREATE VIEW vw_sprNomenclTypeDiagnostic
AS
SELECT m.CodeMUtype,m.NameMUtype,d.code AS TypeDiagnostic,d.name
FROM oms_nsi.dbo.sprNomenclMUtype m left JOIN oms_nsi.dbo.sprTypeDiagnostic d ON
				m.rf_TypeDiagnosticId=d.TypeDiagnosticId
GO
GRANT SELECT ON vw_sprNomenclTypeDiagnostic TO db_RegisterCase