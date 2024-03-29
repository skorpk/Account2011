USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test543]    Script Date: 14.05.2018 8:58:26 ******/
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

insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.rf_idV014>1 AND c.rf_idV014<3 and c.rf_idV006=1 and c.rf_idDirectMO is NULL AND c.DateEnd>='20180501'

insert #tError
select distinct c.id,543
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.rf_idV006=2 and c.rf_idDirectMO is NULL AND c.DateEnd>='20180501'
--поле должно быть заполнено обязательно, если в теге USL присутствует хотя бы одна из услугиз справочника vw_sprMUForDirectMU 
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
						INNER JOIN dbo.vw_sprMUForDirectMU mu ON
			m.MUCode=mu.MU			
where c.rf_idDirectMO is null
