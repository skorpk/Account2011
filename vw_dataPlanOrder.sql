USE RegisterCases
GO
IF OBJECT_ID('vw_dataPlanOrder',N'V') IS NOT NULL
DROP VIEW vw_dataPlanOrder
GO
CREATE VIEW vw_dataPlanOrder
AS
SELECT c.id,c.idRecordCase
		,SUM(CAST((CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS DECIMAL(11,2))) AS Quantity
		,t1.unitCode
		,a.rf_idFiles
FROM t_RegistersCase a INNER JOIN t_RecordCase r ON
			a.id=r.rf_idRegistersCase			
						INNER JOIN t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN t_Meduslugi m ON
			c.id=m.rf_idCase							
						INNER JOIN dbo.vw_sprMU t1 ON
			m.MUCode=t1.MU	
			AND t1.unitCode IS NOT NULL
						LEFT JOIN t_ErrorProcessControl e ON
			c.id=e.rf_idCase
WHERE e.rf_idCase IS NULL AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета
GROUP BY c.id,unitCode,idRecordCase,a.rf_idFiles
UNION ALL
SELECT c.id,c.idRecordCase
		,SUM(CAST((CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS DECIMAL(11,2))) AS Quantity
		,t1.unitCode
		,a.rf_idFiles
FROM t_RegistersCase a INNER JOIN t_RecordCase r ON
			a.id=r.rf_idRegistersCase			
						INNER JOIN t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN t_MES m ON
			c.id=m.rf_idCase							
						INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU 
									UNION ALL 
									SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit
									) t1 ON
			m.MES=t1.MU	
			AND t1.unitCode IS NOT NULL
						LEFT JOIN t_ErrorProcessControl e ON
			c.id=e.rf_idCase
WHERE e.rf_idCase IS NULL AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate--добавил фильтр по дате действия единиц учета												
GROUP BY c.id,unitCode,idRecordCase,a.rf_idFiles
GO