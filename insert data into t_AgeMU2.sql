USE RegisterCases
--SELECT MU,cast(replace('<Root><Age age="'+Age+'" /></Root>',';','" /><Age age="') as xml) AS Age FROM oms_nsi.dbo.sprMUWithAge

INSERT dbo.t_AgeMU2( MU, Age )
SELECT  s.MU,t.col.value('@age','tinyint') AS Age
FROM (
SELECT MU,cast(replace('<Root><Age age="'+Age+'" /></Root>',',','" /><Age age="') as xml) AS Age
		--,CASE WHEN v.Sex='Æ'  THEN 2 ELSE 1 END AS Sex
FROM (VALUES('70.6.13','0'),('70.6.14','1,2'),('70.6.15','3,4'),('70.6.16','5,6'),('70.6.17','7,8,9,10,11,12,13,14'),('70.6.18','15,16,17'),('70.6.19','0'),
			('70.6.20','1,2'),('70.6.21','3, 4'),('70.6.22','5,6'),('70.6.23','7,8,9,10,11,12,13,14'),('70.6.24','15,16,17')) v(MU,Age) 
			 ) s CROSS APPLY s.Age.nodes('/Root/Age') t(col)


/*
INSERT dbo.t_AgeMU2( MU, Sex, Age )
SELECT  '72.1.6',Sex ,Age FROM dbo.t_AgeMU2 WHERE mu='72.1.1'
INSERT dbo.t_AgeMU2( MU, Sex, Age )
SELECT  '72.1.7',Sex ,Age FROM dbo.t_AgeMU2 WHERE mu='72.1.2'
INSERT dbo.t_AgeMU2( MU, Sex, Age )
SELECT  '72.1.8',Sex ,Age FROM dbo.t_AgeMU2 WHERE mu='72.1.3'
INSERT dbo.t_AgeMU2( MU, Sex, Age )
SELECT  '72.1.9',Sex ,Age FROM dbo.t_AgeMU2 WHERE mu='72.1.4'
INSERT dbo.t_AgeMU2( MU, Sex, Age )
SELECT  '72.1.10',Sex ,Age FROM dbo.t_AgeMU2 WHERE mu='72.1.5'
*/
/*
DECLARE @i TINYINT=1
WHILE (@i<19)
BEGIN 
	INSERT dbo.t_AgeMU72_2( MU, AgeStart, TypeAge, AgeEnd )	
	SELECT  '72.2.'+CAST(@i+18 AS VARCHAR(2)) ,AgeStart ,TypeAge ,AgeEnd FROM dbo.t_AgeMU72_2 WHERE MU='72.2.'+CAST(@i AS VARCHAR(2))
	SET @i=@i+1
END 
*/