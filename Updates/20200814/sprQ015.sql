USE RegisterCases
GO
--ALTER TABLE dbo.sprQ015 ADD FieldName VARCHAR(15)

BEGIN TRANSACTION

UPDATE dbo.sprQ015 SET FieldName=SUBSTRING(ID_EL,LEN(ID_EL)-PATINDEX('%[/]%',REVERSE(ID_EL))+2, PATINDEX('%[/]%',REVERSE(ID_EL)) )

SELECT *--ID_EL,SUBSTRING(ID_EL,LEN(ID_EL)-PATINDEX('%[/]%',REVERSE(ID_EL))+2, PATINDEX('%[/]%',REVERSE(ID_EL)) )
FROM dbo.sprQ015

commit

