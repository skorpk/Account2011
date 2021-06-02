USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2018 AND CodeM='101001' AND NumberRegister=60--DateRegistration>'20160425' AND CountSluch>1000
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

select DISTINCT c.id,522, GUID_Case
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase				  		
where a.rf_idFiles=@idFile AND c.rf_idV008=32 AND DateEnd>='20180501' AND 
	NOT EXISTS(SELECT * FROM dbo.t_SlipOfPaper s WHERE rf_idCase=c.id AND s.DateHospitalization IS NOT NULL AND s.GetDatePaper IS NOT NULL AND s.NumberTicket IS NOT NULL)

SELECT * FROM dbo.t_SlipOfPaper WHERE rf_idCase=93366969