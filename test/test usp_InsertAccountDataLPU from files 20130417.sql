use AccountOMS
go
declare @p1 xml,
		@p2 XML,
		@dateStart DATETIME

SELECT @dateStart=GETDATE()		
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HM161007S34001_1308020.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@p2=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\LM161007S34001_1308020.xml',SINGLE_BLOB) LRM (PERS_LIST)
SET STATISTICS TIME ON
exec dbo.usp_TestAccountDataLPU @doc=@p1,@patient=@p2,@file=0x504B0304140000000800B852943F7D81517C,@fileName=N'HM161007S34001_1308020'
SET STATISTICS TIME OFF
