USE AccountOMS
go
SET NOCOUNT ON
DECLARE @t AS TABLE(id UNIQUEIDENTIFIER)
INSERT @t
SELECT c.GUID_Case
FROM t_Case c INNER JOIN t_Mes mes ON
		c.id=mes.rf_idCase
		AND DateEnd>='20130101'
				INNER JOIN dbo.vw_sprMUCompletedCase sm ON
		mes.MES=sm.MU
				LEFT JOIN dbo.t_Meduslugi m ON
		mes.rf_idCase=m.rf_idCase
WHERE sm.MUGroupCode=2 AND sm.MUUnGroupCode=78 AND m.rf_idCase IS NULL

SELECT @@ROWCOUNT

SELECT m.*
FROM RegisterCases.dbo.t_Case c INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
					AND c.DateEnd>='20130101'	
								INNER JOIN @t t ON
					c.GUID_Case=t.id
								INNER JOIN RegisterCases.dbo.t_RecordCaseBack r ON
					c.id=r.rf_idCase
WHERE r.TypePay=1
					
				
						


		
