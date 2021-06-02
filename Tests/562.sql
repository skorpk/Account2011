USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT

select @idFile=id from vw_getIdFileNumber where ReportYear=2019 AND NumberRegister=27 AND CodeM='103001'

select * from vw_getIdFileNumber WHERE id=@idFile
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
--добавить  соединение на vw_sprDentalMuPRVSAge
--
select distinct c.id,562,m.MUCode,m.rf_idV004,c.IsChild,r.ID_Patient,c.idRecordCase
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.IsCompletedCase=0	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Meduslugi m on
			c.id=m.rf_idCase						
						left join vw_sprMuPRVSAge v on
			m.rf_idV004=v.rf_idV015
			and c.IsChild=v.IsChildTariff
			and m.MUCode=v.MUCode
			AND c.DateEnd BETWEEN v.DateBegin AND v.DateEnd
where m.Price>0 and v.MUCode is NULL

SELECT * FROM vw_sprMuPRVSAge WHERE MUCode='4.20.702'
---------------------------Dental MU-----------------

select distinct c.id,562,m.MUSurgery,c.IsChild,m.rf_idV004
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.IsCompletedCase=0	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Meduslugi m on
			c.id=m.rf_idCase						
						INNER join oms_nsi.dbo.vw_sprDentalMuPRVSAge v on			
			m.MUSurgery=v.Code
where NOT EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprDentalMuPRVSAge v WHERE v.code=m.MUSurgery AND v.rf_AgeGroupId=c.IsChild AND v.rf_sprV015RecId=m.rf_idV004)

--SELECT * FROM oms_nsi.dbo.vw_sprDentalMuPRVSAge v WHERE v.code='A16.07.001.003'
-----------------------------------------------------


select distinct c.id,562,c.rf_idv004,m.MES,m.IsCSGTag,c.idRecordCase
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd
						inner join t_Mes m on
			c.id=m.rf_idCase
			--			inner join vw_sprMUCompletedCase mu on
			--m.MES=mu.MU
						left join vw_sprMuPRVSAge v on
			c.rf_idV004=v.rf_idV015
			and c.IsChild=v.IsChildTariff
			and m.MES=v.MUCode
			AND c.DateEnd BETWEEN v.DateBegin AND v.DateEnd
WHERE m.IsCSGTag=1 and v.MUCode is NULL

SELECT * FROM vw_sprMuPRVSAge WHERE MUCode='1.12.193'