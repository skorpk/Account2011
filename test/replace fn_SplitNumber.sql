declare @tableID as TVP_ErrorNumber 
declare @num nvarchar(4000)='4321,4320,4319,4318,4317,4316,4315,4314,4313'
		
DECLARE @idoc int,
        @err int,
        @xml xml
        
select @xml=cast(replace('<Root><Num num="'+@num+'" /></Root>',',','" /><Num num="') as xml)

 EXEC  @err = sp_xml_preparedocument @idoc OUTPUT, @xml
	insert @tableID 
	select num
	from OPENXML(@idoc, '/Root/Num', 1)
			  WITH (num int)

 EXEC sp_xml_removedocument @idoc
select f.id,f.FileNameHR,GETDATE(),fe.DateUnLoad
from t_File f inner join @tableID t on
		f.id=t.id 
			left join t_FileExit fe on
		f.id=fe.rf_idFile		
where fe.rf_idFile is null