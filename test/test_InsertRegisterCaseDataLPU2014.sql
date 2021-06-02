use RegisterCases
go

declare @doc xml,
		@patient xml
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HRM451014T34_1312006.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@patient=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\LRM451014T34_1312006.XML',SINGLE_BLOB) LRM (PERS_LIST)

exec usp_InsertRegisterCaseDataLPU2014 @doc,@patient,0,1376
GO