USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test543]    Script Date: 13.08.2018 14:01:39 ******/
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
--поле должно быть заполнено обязательно, при условии USL_OK=1  и EXTR=1 
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.HopitalisationType=1 and c.rf_idV006=1 and c.rf_idDirectMO is NULL AND c.DateEnd<'20180501'
--до сентября
insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.rf_idV014>1 AND c.rf_idV014<3 and c.rf_idV006=1 AND c.DateEnd>='20180501' AND c.DateEnd<'20180901'
		AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionDate WHERE rf_idCase=c.id AND DirectionDate IS NOT NULL) 
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