USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='805304' and NumberRegister=780 and ReportYear=2016

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

 select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
   a.id=r.rf_idRegistersCase
   and a.rf_idFiles=@idFile 
      inner join t_PatientSMO s on
   r.id=s.ref_idRecordCase
      inner join t_Case c on
   r.id=c.rf_idRecordCase 
   and c.DateEnd>='20121101'
      inner join t_Meduslugi m on
   c.id=m.rf_idCase
   and c.IsCompletedCase=0
   AND m.Price>0
      inner join vw_sprMUAll mu on
   m.MUCode=mu.MU      
where NOT EXISTS(SELECT * FROM vw_sprMuProfilPaymentByAge WHERE MUCode=m.MUCode AND PaymentMethodCode IS NOT null AND PaymentMethodCode=c.rf_idV010 )
 
 select distinct c.id,558
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			and c.DateEnd>='20121101'
			and c.IsCompletedCase=1
						inner join t_MES m on
			c.id=m.rf_idCase
						inner join vw_sprMUAll mu on
			m.MES=mu.MU			
where NOT EXISTS(SELECT * FROM vw_sprMuProfilPaymentByAge WHERE MUCode=m.MES AND PaymentMethodCode IS NOT null AND PaymentMethodCode=c.rf_idV010 )