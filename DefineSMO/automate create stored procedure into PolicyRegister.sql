use RegisterCases
go
if OBJECT_ID('t_SysObjects',N'U') is not null
drop table t_SysObjects
go
create table t_SysObjects
(
	objectID int identity(1,1),
	objName varchar(50),
	objType char(1),
	DateCreate datetime DEFAULT GETDATE(),	
	LoginName varchar(50) DEFAULT SUSER_NAME(),
	objText nvarchar(max),
	DBName varchar(50)
)
go
declare @cmd nvarchar(max)
set @cmd='create proc [dbo].[usp_InsertFilesZP1LPOG]
			@file varchar(26),
			@countRec int,
			--@id int output
			@table as nvarchar(max)
			as
			declare @id int
			insert ZP1LOG(FILENAME,NREC) values(@file,@countRec) 
			set @id=SCOPE_IDENTITY()
			exec usp_InsertZP1 @table,@id'
insert t_SysObjects(objName,objType,objText,DBName) values('usp_InsertFilesZP1LPOG','P',@cmd,'PolicyRegister')

set @cmd='create proc [dbo].[usp_InsertZP1]
			@table as nvarchar(max),
			@ZID int			
			as
			--процедура вставки данных в таблицы для того что бы отправить данные в ЦС ЕРС на определение страховой принадлежности
			declare @tableCaseZPID as table(rf_idRefCaseIteration bigint, zpid int)

			declare @t xml
			select @t=CAST(@table as xml)
			declare @idoc int
			EXEC sp_xml_preparedocument @idoc OUTPUT, @table

			-- вставка в таблицу ZP1
			insert dbo.ZP1(ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS)
				output cast(inserted.RECID as bigint),inserted.ID into @tableCaseZPID
			select @ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS
			FROM OPENXML (@idoc, ''PATIENT/CASE'',2)
				with
					(
						RECID bigint,
						FAM nvarchar(25),
						IM nvarchar(20),
						OT nvarchar(20),
						DR date ,
						W tinyint,
						OPDOC nvarchar(1),
						SPOL nvarchar(20),
						NPOL nvarchar(20),
						DOUT datetime,
						DOCTP nvarchar(2),
						DOCS nvarchar(20),
						DOCN nvarchar(20),
						SS nvarchar(14)
					) 
			exec sp_xml_removedocument @idoc
			-- втсавка в таблицу ERPMSG
			insert into ERPMSG(TP,LPUID,DT,DTO) 
			select ''ZP1'',zpid,getdate(),zp.DOUT
			from @tableCaseZPID t inner join dbo.ZP1 zp on
						t.zpid=zp.ID
			select t.rf_idRefCaseIteration,t.zpid from @tableCaseZPID t'
			
insert t_SysObjects(objName,objType,objText,DBName) values('usp_InsertZP1','P',@cmd,'PolicyRegister')
go
use PolicyRegister
go
declare @s nvarchar(max),
		@objName varchar(50)
		
declare exec_cursor cursor for 
		select objName, objText from RegisterCases.dbo.t_SysObjects where DBName='PolicyRegister' 
open exec_cursor
fetch next from exec_cursor into @objName,@s
while @@fetch_status=0
begin
	if not exists(select * from sys.objects where object_id=OBJECT_ID(@objName) )
	begin
		exec sp_executesql @statement=@s
		--select @objName,@s
	end
	fetch next from exec_cursor into @objName,@s
end
close exec_cursor
deallocate exec_cursor
go

			