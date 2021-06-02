USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='145516' and NumberRegister=1578 and ReportYear=2021

SELECT * FROM dbo.t_ErrorProcessControl e WHERE e.rf_idFile=@idFile AND e.ErrorNumber='535'

--select * from vw_getIdFileNumber where id=@idFile

select distinct c.id,535,s.OKATO,s.rf_idSMO
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase			
			and s.OKATO<>'18000'
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprF002 f on
			s.rf_idSMO=f.SMOKOD
			and s.OKATO=f.TF_OKATO
where (s.rf_idSMO is not null) and f.SMOKOD is null

select distinct c.id,535
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
			and s.OKATO='18000'
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
where s.rf_idSMO is null


--SELECT * FROM vw_sprF002 WHERE SMOKOD='27008'

--SELECT * FROM vw_sprF002 WHERE TF_OKATO IN ('46000')

--SELECT * FROM vw_sprF002 WHERE TF_OKATO IN ('08000')