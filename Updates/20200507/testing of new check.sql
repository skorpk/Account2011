USE RegisterCases
GO
SELECT distinct f.CodeM, a.NumberRegister,db.*,d.RubricName,m.MUCode,c.AmountPayment
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=4
		AND a.ReportYear=2020
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase		
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase						
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.t_ONK_SL o ON
         c.id=o.rf_idCase
				INNER JOIN dbo.t_DiagnosticBlock db ON
         o.id=db.rf_idONK_SL
where f.DateRegistration>'20200401' AND f.DateRegistration<GETDATE() AND m.MUCode LIKE '60.9.%' 

SELECT * FROM vw_sprMGI_N010_N012 WHERE MU='60.9.31'