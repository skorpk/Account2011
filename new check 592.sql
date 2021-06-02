USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='611001' and NumberRegister=97 and ReportYear=2015

select * from vw_getIdFileNumber where id=@idFile
--CREATE TABLE t_AgeMU72_2(MU VARCHAR(9),AgeStart TINYINT,TypeAge CHAR(1),AgeEnd TINYINT)

--INSERT t_AgeMU72_2( MU, AgeStart, TypeAge, AgeEnd )
--SELECT *
--FROM (VALUES ('72.2.1',0,'d',29),('72.2.2',1,'m',2),('72.2.3',2,'m',3),('72.2.3',4,'m',5),('72.2.3',5,'m',6),('72.2.3',7,'m',7),
--			 ('72.2.3',8,'m',9),('72.2.3',10,'m',11),('72.2.3',11,'m',12),('72.2.3',15,'m',16),('72.2.3',21,'m',22),('72.2.3',30,'m',31),
--			 ('72.2.4',3,'m',4),('72.2.5',6,'m',7),('72.2.6',9,'m',10),('72.2.6',18,'m',19),('72.2.7',23,'m',25),('72.2.8',4,'y',null),
--			 ('72.2.8',5,'y',null),('72.2.9',12,'y',null),('72.2.10',12,'m',null),('72.2.11',35,'m',null),('72.2.12',6,'y',null),
--			 ('72.2.13',8,'y',null),('72.2.13',9,'y',null),('72.2.13',13,'y',null),('72.2.14',7,'y',null),('72.2.15',10,'y',null),
--			 ('72.2.16',11,'y',null),('72.2.17',14,'y',null),('72.2.18',15,'y',null),('72.2.18',16,'y',null),('72.2.18',17,'y',null)) v(MU,AgeStart,TypeAge,AgeStop)
SELECT c.id,mes.Mes
		,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1 AS AgeStartDay
		,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1 AS AgeEndDay
		-------------------------------------------------------------------------------		
		,p.BirthDay				
		,c.DateBegin,c.DateEnd
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
WHERE c.id IN (47473796,47474402)	
ORDER BY c.id
/*
Создаем таблицу в которой указываем данные КодЗС, возраст исчисления( месяцы или годы), возраст.
*/
--CREATE UNIQUE NONCLUSTERED INDEX IX_MUAge ON dbo.t_AgeMU72_2(MU,AgeStart) INCLUDE(TypeAge,AgeEnd) 
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
/*Новая проверка в соответствии со служебной запиской №09-28 от 16.02.2015*/
--------------Для детей старше 3 лет--------------------
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
		
select DISTINCT c.id,592,AgeStartDay,AgeEndDay,MES,BirthDay,DateBegin,DateEnd
FROM (
		SELECT c.id,mes.Mes
		,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay)))-1 AS AgeStartDay
		,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay)))-1 AS AgeEndDay
		--убирался раньше один день т.к тип данных не datetime
		--,DATEDIFF(MONTH,p.BirthDay,c.DateBegin)+SIGN(1+SIGN(DAY(c.DateBegin)-DAY(p.BirthDay))) AS AgeStartDay
		--,DATEDIFF(MONTH,p.BirthDay,c.DateEnd)+SIGN(1+SIGN(DAY(c.DateEnd)-DAY(p.BirthDay))) AS AgeEndDay
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


SELECT * FROM t_AgeMU72_2 s WHERE s.MU='72.2.10'
go
--DROP TABLE #tmp_AgeMU72_2
