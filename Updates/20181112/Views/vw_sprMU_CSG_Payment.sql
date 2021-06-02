USE RegisterCases
go
if OBJECT_ID('vw_sprMU_CSG_Payment',N'V') is not NULL
	DROP VIEW vw_sprMU_CSG_Payment
GO
CREATE VIEW vw_sprMU_CSG_Payment
as
select DISTINCT MUCode,PaymentMethodCode
from oms_NSI.dbo.V_MUProfileAndPayment 
UNION ALL
SELECT c.code,pm.Code
FROM oms_nsi.dbo.tCSGroup c INNER JOIN oms_nsi.dbo.tPaymentMethod pm ON
				c.rf_PaymentMethodId=pm.PaymentMethodId
GO
GRANT SELECT ON vw_sprMU_CSG_Payment TO db_RegisterCase