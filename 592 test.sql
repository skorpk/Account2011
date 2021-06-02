USE RegisterCases
GO
SELECT *
FROM  t_MES mes INNER JOIN (select s.MU,t.col.value('@age','tinyint') AS Age
									FROM dbo.vw_sprMUWithAge s CROSS APPLY s.Age.nodes('/Root/Age') t(col)
									) age on
				mes.MES=age.MU
				
select s.MU,t.col.value('@age','tinyint') AS Age
FROM dbo.vw_sprMUWithAge s CROSS APPLY s.Age.nodes('/Root/Age') t(col)				
WHERE s.MU='70.5.8'
				
				
DECLARE @idFile INT=25426				
select c.id,592
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						INNER JOIN vw_sprMUWithAge sa ON
				mes.MES=sa.MU				
						left JOIN (select s.MU,t.col.value('@age','tinyint') AS Age
									FROM dbo.vw_sprMUWithAge s CROSS APPLY s.Age.nodes('/Root/Age') t(col)
									) s on
				c.Age=s.Age
WHERE s.MU IS null
						
