USE RegisterCases
GO
CREATE VIEW vw_MU_VMP_Diag
as
SELECT r.CODE_MU,r.IDHVID AS VID_HMP,r.IDMPAC AS METOD_HMP,r.HGR,m.DS AS DiagnosisCode,m.dateBeg AS dateBegDiag,m.DateEnd AS DateEndDiag,r.dateBeg ,r.dateEnd
FROM oms_nsi.dbo.sprMUV018V019V022Relation r INNER JOIN oms_nsi.dbo.sprVMPMKB m ON
			r.IDHM=m.rf_sprV019V018V022RelationId
GO
GRANT SELECT ON vw_MU_VMP_Diag TO db_RegisterCase
--SELECT * FROM oms_nsi.dbo.sprVMPMKB