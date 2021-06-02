USE RegisterCases
GO
DECLARE @idFile INT

select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='101001' AND ReportYear=2014 AND NumberRegister=26
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

select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join (SELECT * FROM dbo.vw_sprCompletedCaseMUDate UNION ALL SELECT * FROM dbo.vw_sprCSGValid ) t1 on
			c.rf_idMO=t1.CodeM
			AND mes.MES=t1.MU
			and c.DateEnd>=t1.DateBeg
			and c.DateEnd<=t1.DateEnd
where t1.MU is null
--	если на  дату окончания лечения медицинская услуга не разрешена к применению данному медицинскому учреждению
---------------26.03.2013 disable---------------
SELECT distinct mes.rf_idCase,557,mes.MUCode,c.DateBegin,c.DateEnd
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.IsCompletedCase=0
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase				
where NOT EXISTS(SELECT * FROM dbo.vw_sprNotCompletedCaseMUDate t1 WHERE t1.CodeM=c.rf_idMO AND t1.MU=mes.MUCode and t1.DateBeg <=c.DateEnd and t1.DateEnd>=c.DateEnd)

SELECT * FROM dbo.vw_sprNotCompletedCaseMUDate WHERE CodeM=@codeLPU AND MU IN ('57.3.52')
--эта проверка заменяет вышестоящие два скрипта