USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test543]    Script Date: 11.03.2020 8:29:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test543]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--NPR_MO
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join oms_nsi.dbo.sprMO l on
			c.rf_idDirectMO=l.mcod
where c.rf_idDirectMO is not null and l.MCOD is null
--с сентября
--2018-08-13
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.rf_idV014=3 and c.rf_idV006=1 AND c.DateEnd>='20180901' 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionDate WHERE rf_idCase=c.id AND DirectionDate IS NOT NULL) 

--если присутствует NPR_MO, то должно быть и NPR_DATE. Наоборот аналогично
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.rf_idDirectMO IS NOT NULL AND c.DateEnd>='20200301' 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionDate WHERE rf_idCase=c.id AND DirectionDate IS NOT NULL) 

insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_DirectionDate d ON
            c.id=d.rf_idCase
where c.rf_idDirectMO IS  NULL AND c.DateEnd>='20200301' 

insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.rf_idV006=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionDate WHERE rf_idCase=c.id AND DirectionDate IS NOT NULL) AND c.DateEnd>='20180501'

--поле должно быть заполнено обязательно, если в теге USL присутствует хотя бы одна из услугиз справочника vw_sprMUForDirectMU 
SELECT MU INTO #tmu FROM vw_sprMUForDirectMU

insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						INNER JOIN #tmu mu ON
			m.MUCode=mu.MU			
where c.rf_idDirectMO is null

DROP TABLE #tmu