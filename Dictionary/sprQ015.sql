USE RegisterCases
GO
declare @p1 XML,
		@idoc int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\Q015.xml',SINGLE_BLOB) HRM (ZL_LIST)

EXEC sp_xml_preparedocument @idoc OUTPUT, @p1
--поиск записей по VB_P

SELECT ID_TEST,
       USL_TEST,
       VAL_EL
INTO sprQ015_USL_VAL
FROM OPENXML (@idoc, 'packet/zap',2)
	WITH(
			ID_TEST VARCHAR(12),
			USL_TEST VARCHAR(254),
			VAL_EL VARCHAR(254)	
		)
WHERE LEN(USL_TEST)>1 OR LEN(VAL_EL)>1

EXEC sp_xml_removedocument @idoc
GO