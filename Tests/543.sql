USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=232 and ReportYear=2021

select * from vw_getIdFileNumber where id=@idFile

select distinct c.id,543,dd.DirectionDate,rf_idDirectMO
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 	 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						LEFT JOIN dbo.t_DirectionDate dd ON
			c.id=dd.rf_idCase			
where c.rf_idDirectMO is not NULL AND NOT EXISTS(SELECT 1 FROM vw_sprF003 mm WHERE c.rf_idDirectMO=mm.MCOD AND ISNULL(dd.DirectionDate,'22220101') BETWEEN mm.dateBeg AND mm.dateEnd)

SELECT * FROM vw_sprF003 mm WHERE mm.MCOD LIKE '800005'
--с сентября
--2018-08-13
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
go
DROP TABLE #tmu