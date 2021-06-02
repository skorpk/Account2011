USE RegisterCases
GO
declare @idFile INT

SELECT TOP 1 @idFile=id 
FROM dbo.vw_getIdFileNumber 
WHERE ReportYear=2013 AND CodeM='101003' AND NumberRegister=99
ORDER BY id desc

create table #tError (rf_idCase bigint,ErrorNumber smallint)
	
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

/*
проверка на правомочность проведения диспансеризации определенных групп взрослого населения, 
профилактических осмотров взрослого населения, профилактических осмотров несовершеннолетних (далее - Диспансеризация)
*/
DECLARE @dateStartLicense DATE
SELECT @dateStartLicense=DateStart FROM sprLPULicense WHERE CodeM=@codeLPU

INSERT #tError( rf_idCase, ErrorNumber )
SELECT DISTINCT t.id,597
FROM (
		select DISTINCT c.id,c.DateBegin,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile
										inner join t_Case c on
								r.id=c.rf_idRecordCase							
								AND c.DateEnd>=@dateStart 
										inner join dbo.t_Meduslugi m on
								c.id=m.rf_idCase  						
										INNER JOIN AccountOMS.dbo.vw_sprMuWithParamAccount l ON
								m.MUCode=l.MU
								AND m.Price>0
								AND l.AccountParam IS NOT NULL	
										INNER JOIN (VALUES( 'F'),('O'),('R') ) v(Letter) ON
								l.AccountParam=v.Letter
		UNION ALL
		select DISTINCT c.id,c.DateBegin,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile
										inner join t_Case c on
								r.id=c.rf_idRecordCase							
								AND c.DateEnd>=@dateStart 
										inner join dbo.t_MES m on
								c.id=m.rf_idCase  						
										INNER JOIN AccountOMS.dbo.vw_sprMuWithParamAccount l ON
								m.MES=l.MU	
										INNER JOIN (VALUES( 'F'),('O'),('R') ) v(Letter) ON
								l.AccountParam=v.Letter							
		) t
WHERE t.DateBegin<ISNULL(@dateStartLicense,'20100101')
ORDER BY t.id

SELECT * FROM #tError
go
DROP TABLE #tError

