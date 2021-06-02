USE RegisterCases
GO

SELECT f.CodeM,l.NameS
		,t1.unitCode
		,t1.unitName
		,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase					
					INNER JOIN dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN dbo.t_RegisterCaseBack ab ON
			rb.rf_idRegisterCaseBack=ab.id                  
					INNER JOIN dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack
					INNER JOIN dbo.t_PatientBack p ON
			rb.id=p.rf_idRecordCaseBack					
					INNER join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET,unitName FROM dbo.vw_sprMU 
								UNION ALL 
								SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET,UnitName FROM oms_nsi.dbo.vw_CSGPlanUnit
								) t1 on
				m.MES=t1.MU			
				and t1.unitCode is not null		
WHERE f.DateRegistration>'20151101' AND f.DateRegistration<'20151205' AND a.ReportYear=2015 AND a.ReportMonth=11 AND c.rf_idV006=1
		AND cb.TypePay=1 AND p.rf_idSMO<>'34' --IN('34001','34002''34006')
		AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
GROUP BY f.CodeM,l.NameS,t1.unitCode,t1.unitName
UNION ALL
SELECT f.CodeM,l.NameS
		,t1.unitCode
		,t1.unitName
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
FROM dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCase r ON
			a.id=r.rf_idRegistersCase
					INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					inner join dbo.vw_sprMU t1 on
			m.MUCode=t1.MU			
			and t1.unitCode is not null				
					INNER JOIN dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN dbo.t_RegisterCaseBack ab ON
			rb.rf_idRegisterCaseBack=ab.id                  
					INNER JOIN dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack
					INNER JOIN dbo.t_PatientBack p ON
			rb.id=p.rf_idRecordCaseBack					
WHERE f.DateRegistration>'20151101' AND f.DateRegistration<'20151205' AND a.ReportYear=2015 AND a.ReportMonth=11 AND c.rf_idV006=1
		AND cb.TypePay=1 AND p.rf_idSMO<>'34'-- IN('34001','34002''34006')
		AND c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate
GROUP BY f.CodeM,l.NameS,t1.unitCode,t1.unitName
ORDER BY CodeM,unitCode
