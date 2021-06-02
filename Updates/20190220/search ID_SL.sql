USE RegisterCases
GO
select f.CodeM,a.NumberRegister,cc.Code_SL,COUNT(*)
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'												
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN t_Coefficient cc ON
			c.id=cc.rf_idCase 
						INNER JOIN dbo.t_File f ON
			a.rf_idFiles=f.id                      
WHERE f.DateRegistration>'20190110' AND a.ReportYear=2019 AND Code_SL=5
GROUP BY f.CodeM,a.NumberRegister,cc.Code_SL
ORDER BY f.CodeM,cc.Code_SL


select c.Age,m.*,d.DS1,d.DS2
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>='20190101'
							INNER JOIN dbo.t_MES mm ON
				c.id=mm.rf_idCase																		
						INNER JOIN t_Coefficient cc ON
			c.id=cc.rf_idCase 
						INNER JOIN dbo.t_File f ON
			a.rf_idFiles=f.id    
						INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase              
						LEFT JOIN dbo.t_ProfileOfBed m ON
			m.rf_idCase=c.id    
WHERE f.DateRegistration>'20190110' AND a.ReportYear=2019 AND Code_SL=5 AND f.CodeM='161015' AND a.NumberRegister=11

ORDER BY c.id

