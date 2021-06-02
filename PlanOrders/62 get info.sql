USE RegisterCases
GO
DECLARE @idFile int
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='561001' AND ReportYear=2018 AND NumberRegister=125

SELECT c.id,c.IsCompletedCase,m.MES, t1.unitCode
FROM dbo.t_ErrorProcessControl e INNER JOIN t_Case c ON
			e.rf_idCase=c.id
							INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase 
					INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=2 
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
							) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL                         
WHERE e.rf_idFile=@idFile AND ErrorNumber=62 AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate

SELECT c.id,c.IsCompletedCase,m.MES, t1.unitCode
FROM dbo.t_ErrorProcessControl e INNER JOIN t_Case c ON
			e.rf_idCase=c.id
							INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase 
					INNER JOIN (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
							) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL                         
WHERE e.rf_idFile=@idFile AND ErrorNumber=62 AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate

SELECT *
FROM dbo.vw_sprUnit WHERE unitCode IN(144,260)

SELECT *
FROM dbo.vw_sprUnit WHERE unitName LIKE '%ÄÂÍ%'
SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE MU='72.1.1'

select * from vw_sprMuWithParamAccount where MU='72.1.1'

