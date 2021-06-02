use RegisterCases
go
declare @p1 xml,
		@ip int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\20120203\HRT34_M431001120106.xml',SINGLE_BLOB) HRM (ZL_LIST)
declare @t as table(id_c uniqueidentifier, pay tinyint)

EXEC sp_xml_preparedocument @ip OUTPUT, @p1

--insert @t
select ID_C,OPLATA
FROM OPENXML (@ip, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE int ,
			ID_C uniqueidentifier,
			OPLATA tinyint
		)
where OPLATA=1
EXEC sp_xml_removedocument @ip