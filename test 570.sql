USE RegisterCases
GO
DECLARE @idFile INT

select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='101002' AND ReportYear=2014 AND NumberRegister=22
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						left join vw_sprV002 v on
			m.rf_idV002=v.id
where v.id is null						
---------------2014-02-04---------------

select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			--and c.rf_idV002!=134	
						INNER JOIN dbo.vw_IsSpecialCase s ON
			c.IsSpecialCase=s.OS_SLUCH
			AND s.IsClinincalExamination=0
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002
--16.12.2013 добавил в представлени vw_idCaseWithOutPRVSandProfilCompare что проверка не производиться по КСГ

select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase
						LEFT JOIN vw_idCaseWithOutPRVSandProfilCompare ce ON
			c.id=ce.id
			AND ce.rf_idFiles=@idFile				
where ce.id IS NULL and c.rf_idV002<>m.rf_idV002
--2014-02-27

select distinct c.id,570
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join (SELECT rf_idRecordCase,id,rf_idV002,IsSpecialCase from t_Case WHERE rf_idV010<>33 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
			r.id=c.rf_idRecordCase
			and c.rf_idV002!=158
			AND c.IsSpecialCase IS null	
						inner join t_Meduslugi m on
			c.id=m.rf_idCase			
where c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * from vw_idCaseWithOutPRVSandProfilCompare 
											  WHERE rf_idFiles=@idFile AND DateEnd>=@dateStart AND DateEnd<@dateEnd AND id=c.id)
