USE RegisterCases
go
SET NOCOUNT ON
DECLARE @idFile INT

SELECT DISTINCT TOP 1 @idFile=f.id
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.DateRegistration>='20130321'
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_MES mes on
		c.id=mes.rf_idCase
				INNER JOIN vw_sprMUCompletedCase m ON
		m.MUGroupCode=2 AND m.MUUnGroupCode=78
		AND mes.MES=m.MU


select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
							inner join (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
										) mc on
				mes.MES=mc.MU
							INNER JOIN t_Meduslugi m on
				mes.rf_idCase=m.rf_idCase
WHERE m.MUCode NOT LIKE '2.3.%'

select c.id,591
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase				
							INNER JOIN t_Meduslugi m on
				c.id=m.rf_idCase
									LEFT JOIN (SELECT rf_idCase,Mes 
												from t_MES mes inner join (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																			  UNION ALL
																			  SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																			  UNION ALL
																			  SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																			  ) mc on
														mes.MES=mc.MU
												) mes ON c.id=mes.rf_idCase
WHERE m.MUCode like '2.3.%' AND mes.rf_idCase IS NULL
go