USE RegisterCases
GO
DROP TABLE dbo.sprQ015
go
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\Q015.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1
--поиск записей по VB_P

SELECT ROW_NUMBER() OVER(ORDER BY ID_TEST) AS ID, ID_TEST,
       ID_EL,
       COMMENT,
       DATEBEG
INTO sprQ015
FROM OPENXML (@idoc, 'packet/zap',2)
	WITH(
			ID_TEST VARCHAR(12),
			ID_EL VARCHAR(50),
			COMMENT VARCHAR(100),			
			DATEBEG date
		)

EXEC sp_xml_removedocument @idoc
GO