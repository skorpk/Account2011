USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='254505' and NumberRegister=100 and ReportYear=2017

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

select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						left join vw_sprV004 v on
			m.rf_idV004=v.id
			AND c.DateEnd>=v.DateBeg
			AND c.DateEnd<=v.DateEnd 
where v.id is null


select distinct c.id,577
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			--AND c.IsSpecialCase IS NULL			
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						inner join vw_sprMU mu on
			m.MUCode=mu.MU
			LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
WHERE c.rf_idV002<>158 and ce.id IS NULL and c.rf_idV004<>m.rf_idV004
