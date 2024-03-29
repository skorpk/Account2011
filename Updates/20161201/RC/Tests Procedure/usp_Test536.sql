USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test536]    Script Date: 26.01.2017 9:32:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test536]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--SMO_OK
insert #tError
select distinct c.id,536
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprOKATO f on
			s.OKATO=f.OKATO
where f.OKATO is NULL AND NOT EXISTS(SELECT * FROM (VALUES('35000') ) v(OKATO) WHERE v.OKATO=s.OKATO)
--------------------ST_OKATO-------------------------------
insert #tError
select distinct c.id,536
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprOKATO f on
			s.ST_OKATO=f.OKATO
WHERE s.ST_OKATO IS NOT NULL and f.OKATO is NULL AND NOT EXISTS(SELECT * FROM (VALUES('35000') ) v(OKATO) WHERE v.OKATO=s.ST_OKATO)
GO