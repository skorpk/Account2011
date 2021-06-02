USE RegisterCases
GO
CREATE VIEW vw_sprCSGWage
as
SELECT CSGroupId,c.code,c.name,coefficient,c.dateBeg,c.dateEnd
FROM dbo.vw_sprCSG c INNER JOIN oms_nsi.dbo.tCSGWage w ON
				c.CSGroupId=w.rf_CSGroupID
GO
GRANT SELECT ON vw_sprCSGWage TO db_RegisterCase