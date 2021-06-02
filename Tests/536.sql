USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='431001' and NumberRegister=130 and ReportYear=2016

select * from vw_getIdFileNumber where id=@idFile

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

--SELECT * FROM vw_sprF002 WHERE TF_OKATO='46000'

--SELECT * FROM vw_sprF002 WHERE SMOKOD IN ('31002','50049')