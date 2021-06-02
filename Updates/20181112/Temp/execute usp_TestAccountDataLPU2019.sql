use AccountOMS
go
declare @p1 xml,
		@p2 XML,
		@dateStart DATETIME

SELECT @dateStart=GETDATE()		
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\HM151005S34007_181100001.xml',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@p2=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'd:\Test\LM151005S34007_181100001.xml',SINGLE_BLOB) LRM (PERS_LIST)

SET STATISTICS TIME ON


exec dbo.usp_TestAccountDataLPUFileH2019 @doc=@p1,@patient=@p2,@fileName=N'HM151005S34007_181100001'
--exec dbo.usp_TestAccountDataLPUFileH @doc=@p1,@patient=@p2,@fileName=N'HM103001S34007_180800001'

SET STATISTICS TIME OFF

--SELECT * FROM dbo.t_Errors WHERE rf_idFileError=32072

