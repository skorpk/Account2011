USE AccountOMS
GO
DECLARE @idFile INT=96486

select distinct c.GUID_Case,c.id,mes
from t_RegistersAccounts a inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
		AND a.rf_idFiles=@idFile
				inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
				inner join t_MES mes on
		c.id=mes.rf_idCase
				INNER JOIN (
								SELECT DISTINCT MU
								FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																		UNION ALL
																		SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																		) m1 ON
											m.MU=m1.MUCode
								WHERE m1.MUCode IS NULL
							  ) vw_c ON
			mes.MES=vw_c.MU
				INNER JOIN dbo.t_Meduslugi m ON
			mes.rf_idCase=m.rf_idCase
