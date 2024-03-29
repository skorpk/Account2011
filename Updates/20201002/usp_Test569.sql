USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test569]    Script Date: 02.10.2020 8:51:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test569]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--LPU
--19.01.2016 Для тех МУ которые не в справочнике значения олжны совпадать.
--кроме услуг 4.%
insert #tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.rf_idMO<>m.rf_idMO
WHERE m.MUCode NOT LIKE '4.%' AND NOT EXISTS(SELECT * FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.MU=m.MUCode)
--Если МУ из справочника и признак 1 то на уровне медуслуг должен стоят код из этого справочника
insert #tError
select distinct c.id,569
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
insert #tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER join vw_sprMUAllowDiffrentCodeM mu ON
			m.MUCode=mu.MU                      
WHERE mu.IsOnlyMO=0 and NOT EXISTS(SELECT 1 FROM vw_sprMUAllowDiffrentCodeM mo WHERE mo.IsOnlyMO=0 AND m.rf_idMO IN(mo.CodeM,'000000','999999')
									UNION ALL 
									SELECT 1 FROM dbo.t_Meduslugi mo WHERE mo.rf_idMO IN(m.rf_idMO,'000000','999999') AND mo.rf_idCase=c.id
									)

----------------------------------------------------------------------------------------
----2020-10-02 Для услуг из класса 4.% LPU может быть равно «000000» (Патологоанатомическое бюро) или «999999»(другое МО) 
insert #tError
select distinct c.id,569
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
			and c.rf_idMO<>m.rf_idMO
WHERE m.MUCode LIKE '4.%' AND NOT EXISTS(SELECT 1 FROM vw_sprMUAllowDiffrentCodeM mo WHERE m.rf_idMO IN (mo.CodeM,'000000','999999') )