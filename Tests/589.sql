USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
		@CaseDefined TVP_CasePatient

select @idFile=id from vw_getIdFileNumber where CodeM='351001' and NumberRegister=83 and ReportYear=2019

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

INSERT @CaseDefined
select c.id,r.id
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_ErrorProcessControl e ON
				c.id=e.rf_idCase
WHERE e.ErrorNumber=589

SELECT * FROM @CaseDefined				                      
	

IF EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprT001 WHERE CodeM=@codeLPU AND pfs=1 )
BEGIN
	select c.id,589
	from @CaseDefined cd inner join t_Case c on
					cd.rf_idCase=c.id
					and c.rf_idV006=4					
						inner join t_Meduslugi m on
					c.id=m.rf_idCase										 
	where NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.v001 WHERE IDRB=m.MUCode AND isTelemedicine=1
					 UNION ALL 
					 SELECT 1 FROM vw_sprMUSplitByGroup mu WHERE m.MUCode=mu.MU and mu.MUGroupCode=71 and mu.MUUnGroupCode IN (1 ,3))
	group by c.id
END