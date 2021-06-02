USE RegisterCases
GO
if OBJECT_ID('vw_CoefficientAvr',N'V') is not NULL
	DROP VIEW vw_CoefficientAvr
GO
CREATE VIEW vw_CoefficientAvr
AS
SELECT c.rf_idCase, SUM(c.Coefficient)/CAST(COUNT(c.rf_idCase) AS DECIMAL(3,2)) AS AvrValc, COUNT(c.rf_idCase) AS CountIT_SL
FROM t_Coefficient c GROUP BY c.rf_idCase
GO
GRANT SELECT ON  vw_CoefficientAvr TO db_RegisterCase