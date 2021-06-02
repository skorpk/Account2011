set NOCOUNT on
go
declare @str nvarchar(max)='',
		@table varchar(50)='t_RegisterPatientAttendant'

select  @str=@str+QUOTENAME(COLUMN_NAME)+','
from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=@table

select 'SET IDENTITY_INSERT dbo.'+@table+' ON'+CHAR(13)+'insert dbo.'+@table+'('+@str+')'+CHAR(13)+
		'select '+@str+CHAR(13)+'from tmp_'+right(@table,LEN(@table)-2)+CHAR(13)+
		'SET IDENTITY_INSERT dbo.'+@table+' OFF'

