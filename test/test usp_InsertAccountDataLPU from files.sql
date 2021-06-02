use AccountOMS
go
declare @p1 xml,
		@p2 xml
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HM155306S34001_1309004.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@p2=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\LM155306S34001_1309004.xml',SINGLE_BLOB) LRM (PERS_LIST)
declare @t as table(rf_idFile int, IsError bit)
--insert @t
--BEGIN TRANSACTION
SET STATISTICS TIME ON
exec usp_InsertAccountDataLPU @doc=@p1,@patient=@p2,@file=0x504B0304140000000800B852943F7D81517C,@fileName=N'HM155306S34001_1309004'
SET STATISTICS TIME OFF
--ROLLBACK
--select e.* 
--from t_Errors e inner join @t t on
--		e.rf_idFileError=t.rf_idFile