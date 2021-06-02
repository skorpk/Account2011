USE RegisterCases
GO

select DISTINCT f.id,f.CodeM,a.NumberRegister--, d.DS1
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=3
		AND a.ReportYear=2018
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase            
where f.DateRegistration>'20180305' AND f.TypeFile='F' AND c.rf_idV009=318 AND c.IsNeedDisp IN (1,2)
ORDER BY f.id

select DISTINCT f.id,f.CodeM,a.NumberRegister--, d2.DiagnosisCode
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=3
		AND a.ReportYear=2018
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase              
where f.DateRegistration>'20180305' AND f.TypeFile='F' AND c.rf_idV009=318 AND ISNULL(d2.IsNeedDisp,9) IN(1,2)
ORDER BY f.id