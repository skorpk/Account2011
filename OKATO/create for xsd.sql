DECLARE @idoc int
DECLARE @Doc xml

SELECT	 @Doc		= E.Error				
FROM	OPENROWSET(BULK 'c:\Test\sprSMO.xml',SINGLE_BLOB)E(Error)

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
--declare @i smallint=1,
--		@item varchar(50)
--while @i<17
--begin
--	set @item='/root/item'+CAST(@i as VARCHAR(3))
declare @t as table(OKATO char(5))
	
	insert @t
	SELECT distinct TF_OKATO
	FROM OPENXML (@idoc, '/root/rec')
	WITH 
	(	
		ADDR_F nvarchar(100) './@ADDR_F',
		NAM_SMOK nvarchar(100) './@NAM_SMOK',
		SMOKOD int './@SMOCOD',
		TF_OKATO char(5) './@TF_OKATO'
	)
	order by TF_OKATO
--	set @i=@i+1
--end
EXEC sp_xml_removedocument @idoc

select '<xs:enumeration value="'+OKATO+'"/>' from @t
