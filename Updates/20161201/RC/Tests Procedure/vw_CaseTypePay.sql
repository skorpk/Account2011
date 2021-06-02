USE RegisterCases
GO
--DROP VIEW	vw_CaseTypePay
--go
CREATE VIEW vw_CaseTypePay
as
SELECT c.GUID_Case,c1.TypePay
FROM t_Case c INNER JOIN dbo.t_RecordCaseBack r ON
		c.id=r.rf_idCase
			  INNER JOIN dbo.t_CaseBack c1 ON
			r.id=c1.rf_idRecordCaseBack
GO
GRANT SELECT ON vw_CaseTypePay TO db_RegisterCase