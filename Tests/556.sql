USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='141023' and NumberRegister=47 and ReportYear=2015

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

  select distinct c.id,556,m.MES,c.IsChildTariff,c.rf_idV002
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd	
						inner join dbo.t_MES m on
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUCompletedCase s ON
			m.MES=s.MU
						left join (SELECT * FROM vw_sprMuProfilPaymentByAge) v on
			c.IsChildTariff=v.Age
			AND c.rf_idV002=v.ProfileCode
			and m.MES=v.MUCode
where v.MUCode is NULL

SELECT * FROM vw_sprMuProfilPaymentByAge v WHERE v.MUCode='1.12.13'