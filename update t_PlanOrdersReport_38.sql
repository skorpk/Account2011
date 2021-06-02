USE RegisterCases
GO

DECLARE @t AS TABLE(CodeLPU CHAR(8))
INSERT @t( CodeLPU )
VALUES ('10500118'),('10500213'),('10500811'),('13502013'),('15500115'),('16501516'),('25502725'),('39500139')

/*
SELECT l.CodeLPU,UnitCode
FROM dbo.t_PlanOrdersReport p INNER JOIN @t l ON
			p.CodeLPU=left(l.CodeLPU,6)
WHERE YearReport=2014  AND UnitCode=30
GROUP BY l.CodeLPU, UnitCode
ORDER BY l.CodeLPU,UnitCode

SELECT * FROM dbo.t_PlanOrdersReport  
WHERE rf_idFile=53981 AND rf_idFileBack=95172 AND UnitCode IN (30,38)

DELETE FROM dbo.t_PlanOrdersReport  
WHERE rf_idFile=53981 AND rf_idFileBack=95172 AND UnitCode IN (30)

SELECT rf_idFile,rf_idFileBack
FROM dbo.t_PlanOrdersReport p INNER JOIN @t l ON
				p.CodeLPU=left(l.CodeLPU,6)
WHERE YearReport=2014 AND UnitCode IN (30,38)
GROUP BY rf_idFile,rf_idFileBack
HAVING COUNT(*)>1
*/

BEGIN TRANSACTION
	UPDATE p SET UnitCode=38
	FROM dbo.t_PlanOrdersReport p INNER JOIN @t l ON
				p.CodeLPU=left(l.CodeLPU,6)
	WHERE YearReport=2014  AND UnitCode=30
COMMIT
GO
