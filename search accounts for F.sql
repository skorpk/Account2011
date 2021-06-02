USE AccountOMS
GO
CREATE TABLE #tmp_AgeMU72_2(MU VARCHAR(9),AgeStart TINYINT,TypeAge CHAR(1),AgeEnd TINYINT)

INSERT #tmp_AgeMU72_2( MU, AgeStart, TypeAge, AgeEnd )
SELECT *
FROM (VALUES ('72.2.1',0,'d',29),('72.2.2',1,'m',2),('72.2.3',2,'m',3),('72.2.3',4,'m',5),('72.2.3',5,'m',6),('72.2.3',7,'m',7),
			 ('72.2.3',8,'m',9),('72.2.3',10,'m',11),('72.2.3',11,'m',12),('72.2.3',15,'m',16),('72.2.3',21,'m',22),('72.2.3',30,'m',31),
			 ('72.2.4',3,'m',4),('72.2.5',6,'m',7),('72.2.6',9,'m',10),('72.2.6',18,'m',19),('72.2.7',23,'m',25),('72.2.8',4,'y',null),
			 ('72.2.8',5,'y',null),('72.2.9',12,'y',null),('72.2.10',12,'m',null),('72.2.11',35,'m',null),('72.2.12',6,'y',null),
			 ('72.2.13',8,'y',null),('72.2.13',9,'y',null),('72.2.13',13,'y',null),('72.2.14',7,'y',null),('72.2.15',10,'y',null),
			 ('72.2.16',11,'y',null),('72.2.17',14,'y',null),('72.2.18',15,'y',null),('72.2.18',16,'y',null),('72.2.18',17,'y',null)) v(MU,AgeStart,TypeAge,AgeStop)
			 
			 
SELECT f.CodeM,a.NumberRegister,COUNT(c.id)--,mes.Mes,p.BirthDay,c.DateEnd,c.DateBegin
from t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			  inner join dbo.t_RecordCasePatient r on
			a.id=r.rf_idRegistersAccounts
					inner join t_Case c on
			r.id=c.rf_idRecordCasePatient
					inner join t_MES mes on
			c.id=mes.rf_idCase									
					INNER JOIN dbo.t_RegisterPatient p ON						
			f.id=p.rf_idFiles
			and r.id=p.rf_idRecordCase			
WHERE f.DateRegistration>'20150120' AND f.DateRegistration<'20150228' AND a.ReportYear=2015 AND a.ReportMonth=1 AND c.Age<3 AND a.Letter='F'
		AND mes.MES='72.2.6'			 
GROUP BY f.CodeM,a.NumberRegister
GO
DROP TABLE #tmp_AgeMU72_2
