USE AccountOMS
GO
declare @doc xml

SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HM103001S34001_1604001.xml',SINGLE_BLOB) HRM (ZL_LIST)

DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile INT

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
SELECT IDCASE,ID_C,CODE_SL,VAL_C
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/SL_KOEFF/COEFF',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			CODE_SL SMALLINT,
			VAL_C DECIMAL(3,2) 
	)	

EXEC sp_xml_removedocument @idoc        