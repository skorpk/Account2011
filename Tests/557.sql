USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='551001' AND ReportYear=2020 AND NumberRegister=32

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

  ---557
--4.по дате окончания лечения проводится проверка на правомочность применения медицинской организацией указанного кода законченного случая. Проверка проводится в соответствии со справочником разрешенных к применению медицинских услуг
---------------11.04.2014 disable---------------
select mes.rf_idCase,557,mes, c.DateEnd
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase                      
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase
						left join (SELECT * FROM dbo.vw_sprCompletedCaseMUDate UNION ALL SELECT * FROM dbo.vw_sprCSGValid ) t1 on
			(CASE WHEN c.DateEnd>'20170731' AND c.DateEnd<'20180101' AND c.rf_idV006=1 AND c.rf_idMO IN ('101003', '103001', '131001', '171004') THEN c.rf_idDepartmentMO ELSE c.rf_idMO END)=t1.CodeM
			AND mes.MES=t1.MU
			and cc.DateEnd>=t1.DateBeg
			and cc.DateEnd<=t1.DateEnd
where t1.MU is NULL

SELECT * FROM dbo.vw_sprCSGValid WHERE MU='st23.004' AND CodeM=@codeLPU
--	если на  дату окончания лечения медицинская услуга не разрешена к применению данному медицинскому учреждению

---------------26.03.2013 disable---------------
 select mes.rf_idCase,557,mes.mucode, c.rf_idMO
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase  
				--AND c.IsCompletedCase=0
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase	
						INNER JOIN dbo.vw_sprMU sm ON
				mes.MUCode=sm.MU			
where NOT EXISTS(SELECT * FROM dbo.vw_sprNotCompletedCaseMUDate t1 WHERE t1.CodeM=c.rf_idMO AND t1.MU=mes.MUCode and t1.DateBeg <=cc.DateEnd and t1.DateEnd>=cc.DateEnd)

SELECT DISTINCT CodeM FROM dbo.vw_sprNotCompletedCaseMUDate t1 WHERE t1.MU='2.78.12'

--смотрим есть ли медуслуга в справочнике.
select mes.rf_idCase,557
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_Meduslugi mes on
				c.id=mes.rf_idCase					
where NOT EXISTS(SELECT * FROM dbo.vw_sprMU_V001_Dental t1 WHERE t1.MU=mes.MUCode )
