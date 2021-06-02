USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber  where CodeM='145516' and NumberRegister=1228 and ReportYear=2018

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
--устанавливаем дату начала и дату окончани€ отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

select c.id,592
FROM (
		SELECT c.id,mes.Mes,YEAR(c.DateBegin)-YEAR(p.BirthDay) AS Age,p.rf_idV005
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase	
								INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=3
											UNION ALL 
											SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=1
											/*UNION ALL 
											SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=2*/) mc on
						mes.MES=mc.MU
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
			) c	 INNER JOIN dbo.t_AgeMU2 s on
						s.MU=c.MES
WHERE NOT EXISTS(SELECT * FROM dbo.t_AgeMU2 s WHERE s.MU=c.MES AND s.Age=c.Age and ISNULL(s.Sex,c.rf_idV005)=c.rf_idV005)
/*Ќова€ проверка в соответствии со служебной запиской є09-28 от 16.02.2015*/
--------------ƒл€ детей старше 3 лет--------------------
SELECT DISTINCT c.id,592
FROM (
		SELECT c.id,mes.Mes,YEAR(c.DateBegin)-YEAR(p.BirthDay) AS Age				
				,c.DateEnd,c.DateBegin
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase									
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
		WHERE mes.MES LIKE '72.2.%'
			) c	 INNER JOIN t_AgeMU72_2 s on
						s.MU=c.MES
WHERE s.TypeAge='y' AND	NOT EXISTS(SELECT * FROM t_AgeMU72_2 s WHERE s.MU=c.MES AND s.AgeStart=c.Age AND DATEDIFF(yyyy,c.DateBegin,c.DateEnd)=0)

-----------новорожденные----------------------
SELECT DISTINCT c.id,592
FROM (
		SELECT c.id,mes.Mes,datediff(d,p.BirthDay,c.DateBegin) AS AgeStartDay,datediff(d,p.BirthDay,c.DateEnd)	AS AgeEndDay
				,c.DateEnd,c.DateBegin
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase									
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
		WHERE mes.MES LIKE '72.2.%'
			) c	 INNER JOIN t_AgeMU72_2 s on
						s.MU=c.MES
WHERE s.TypeAge='d' AND	NOT EXISTS(SELECT * FROM t_AgeMU72_2 s WHERE s.MU=c.MES AND s.AgeStart<=c.AgeStartDay AND c.AgeEndDay<=s.AgeEnd)
-----------------и дети до 3 лет включительно----------------------
DECLARE @dt DATETIME=CAST(year(GETDATE()) AS CHAR(4))+'1231 23:59:59',
		@dt1 DATETIME=GETDATE()
		
select DISTINCT c.id,592 ,c.*
FROM (
		SELECT c.id,mes.Mes				
		,CASE WHEN c.DateBegin<>DATEADD(month,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1, p.BirthDay) 
						THEN  DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1 
						ELSE DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1 END AS AgeStartDay
		----------------------------------------------------------------------------------------------------------------------------------		
		,CASE WHEN c.DateEnd<>DATEADD(month,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1, p.BirthDay) 
						THEN  DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1 
						ELSE DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1 END AS AgeEndDay
				,c.DateEnd,c.DateBegin,p.BirthDay
		from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
								inner join t_Case c on
						r.id=c.rf_idRecordCase	
						AND ISNULL(c.Comments,'10')NOT IN (N'11',N'21')
								inner join t_MES mes on
						c.id=mes.rf_idCase									
								INNER JOIN dbo.vw_RegisterPatient p ON
						p.rf_idFiles=@idFile
						and r.id=p.rf_idRecordCase						
		WHERE mes.MES LIKE '72.2.%'
			) c	 INNER JOIN t_AgeMU72_2 s on
						s.MU=c.MES
WHERE s.TypeAge='m' AND	NOT EXISTS(SELECT *	FROM t_AgeMU72_2 s
								   WHERE s.MU=c.MES AND s.AgeStart<=c.AgeStartDay AND 
										c.AgeEndDay<=(CASE WHEN AgeEnd IS NULL THEN c.AgeStartDay + DATEDIFF(MONTH,@dt1,@dt)+SIGN(1+SIGN(DAY(@dt)-DAY(@dt1)))  ELSE AgeEnd END)
									)

SELECT * FROM t_AgeMU72_2 WHERE MU='72.2.42'

SELECT * FROM t_AgeMU72_2 WHERE MU='72.2.40'


--2 вариант,если в качестве кода «— используютс€ коды из групп 70.5.*, 70.6.*, 72.3.*,  то возраст рассчитываетс€ в обычном пор€дке (равен значению в поле AGE).
select c.id,592
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND ISNULL(c.Comments,N'10') NOT IN (N'11',N'21')
						inner join t_MES mes on
				c.id=mes.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=3
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=5
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=6
									) mc on
				mes.MES=mc.MU
						INNER JOIN dbo.vw_RegisterPatient p ON
				p.rf_idFiles=@idFile
				and r.id=p.rf_idRecordCase	
						INNER JOIN dbo.t_AgeMU2 s on
						s.MU=mes.MES	
WHERE NOT EXISTS(SELECT * FROM dbo.t_AgeMU2 s WHERE s.MU=mes.MES AND s.Age=c.Age AND ISNULL(s.Sex,p.rf_idV005)=p.rf_idV005)
