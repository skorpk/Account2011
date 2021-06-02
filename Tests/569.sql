USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='145516' and NumberRegister=1008 and ReportYear=2017

select * from vw_getIdFileNumber where id=@idFile


--19.01.2016 Для тех МУ которые не в справочнике значения олжны совпадать.

select distinct c.id,569,1,MUCode,c.rf_idMO,m.rf_idMO
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.rf_idMO<>m.rf_idMO
WHERE NOT EXISTS(SELECT * FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.MU=m.MUCode)

--SELECT * FROM vw_sprMUAllowDiffrentCodeM WHERE MU='4.11.538'
--Если МУ из справочника и признак 1 то на уровне медуслуг должен стоят код из этого справочника
select distinct c.id,569,2,m.MUCode
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER join vw_sprMUAllowDiffrentCodeM mu ON
			m.MUCode=mu.MU                      
WHERE mu.IsOnlyMO=1 and NOT EXISTS(SELECT * FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.IsOnlyMO=1 AND mo.CodeM=m.rf_idMO)

--Если МУ из справочника и признак 0 то на уровне медуслуг должен стоят код из этого справочника или код выставившей МО
select distinct c.id,569,3
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER join vw_sprMUAllowDiffrentCodeM mu ON
			m.MUCode=mu.MU                      
WHERE mu.IsOnlyMO=0 and NOT EXISTS(SELECT 1 FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.IsOnlyMO=0 AND mo.CodeM=m.rf_idMO
									UNION ALL 
									SELECT 1 FROM dbo.t_Meduslugi mo WHERE mo.rf_idMO=m.rf_idMO AND mo.rf_idCase=c.id
									)