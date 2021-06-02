use RegisterCases
go
if OBJECT_ID('usp_GetsprT001',N'P') is not null
drop proc usp_GetsprT001
go
create procedure usp_GetsprT001
				@CodeM varchar(6)
as 
select COUNT(*)
from oms_nsi.dbo.vw_sprT001
where CodeM=@CodeM
go
----------------------------------------------------------------------------
if OBJECT_ID('usp_IsFileNameExists',N'P') is not null
drop proc usp_IsFileNameExists
go
create procedure usp_IsFileNameExists
				@fileName varchar(26)
as 

select COUNT(*) from t_File where upper(FileNameHR)= UPPER(rtrim(ltrim(@fileName)))
go
---------------------------------------------------------------------------
if OBJECT_ID('usp_SetGlobalError',N'P') is not null
drop proc usp_SetGlobalError
go
create proc usp_SetGlobalError
			@fileName varchar(26),
			@errorId int=0
as
/*Данная процедура вызывается для фиксации глобальных ошибок в бд. Это ошибки с номером <900.*/
begin transaction

begin try
declare @idFileTest int
	
	insert t_FileTested(DateRegistration,[FileName],UserName) values(GETDATE(),@fileName,ORIGINAL_LOGIN())
	
	select @idFileTest=SCOPE_IDENTITY()
	
	insert t_FileError(rf_idFileTested,DateCreate,[FileNameP]) values(@idFileTest,GETDATE(),'P'+@fileName)
	select @idFileTest=SCOPE_IDENTITY()
	
	declare @t as table(id int,NameFile varchar(26))
		
	declare @t1 int, @t2 int
	
	insert t_FileNameError(rf_idFileError,[FileName]) 
	values(@idFileTest,@fileName)
	select @t1=SCOPE_IDENTITY()
	
	insert t_FileNameError(rf_idFileError,[FileName]) 
	values(@idFileTest,'L'+RIGHT(@fileName,LEN(@fileName)-1))
	select @t2=SCOPE_IDENTITY()	
	
	if @errorId>0
	begin
		insert t_Error(rf_idFileNameError,rf_idF012,Comments) 
		select @t1,@errorId, AdditionalInfo 
		from dbo.vw_sprF012 
		where id=@errorId
	end
	
	select FileNameP 'FNAME', [FileName] 'FNAME_I', ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
	from vw_GlobalError
	where id=@idFileTest and id1=@t1	
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
	
	select FileNameP 'FNAME', [FileName] 'FNAME_I', ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
	from vw_GlobalError
	where id=@idFileTest and id1=@t2	
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
		
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
go


-----------------------------------------------------------------------------------------------------------
if OBJECT_ID('usp_SetGlobalXSDError',N'P') is not null
	drop proc usp_SetGlobalXSDError
go
create proc usp_SetGlobalXSDError
			@errorTable as TVP_Error READONLY,
			@file varchar(26),
			@fileID int=0
as
begin transaction

begin try
declare @idFileTest int
	
	if @fileID=0
	begin
		insert t_FileTested(DateRegistration,[FileName],UserName) 
		select GETDATE(),@file,ORIGINAL_LOGIN()
		
		select @idFileTest=SCOPE_IDENTITY()
	end
	else 
	begin
		select @idFileTest=rf_idFileTested from t_File where id=@fileID
	end
	
	insert t_FileError(rf_idFileTested,DateCreate,[FileNameP]) 
	values(@idFileTest,GETDATE(),'P'+@file)
	
	select @idFileTest=SCOPE_IDENTITY()
	
	declare @t as table(id int,NameFile varchar(26))
	
	insert t_FileNameError(rf_idFileError,[FileName]) 
	output inserted.id,inserted.FileName into @t
	values(@idFileTest,@file),(@idFileTest,'L'+RIGHT(@file,LEN(@file)-1))
	
	insert t_Error(rf_idFileNameError,rf_idF012,rf_idXMLElement,rf_idGuidFieldError,ErrorTagAlter,ErrorParentTagAlter)
	select t1.id,e.ErrorNumber,el.id,e.ErrorValue,e.ErrorTag,e.ErrorParentTag
	from @errorTable e left join vw_XmlTag el on
				LTRIM(rtrim(e.ErrorTag))=ltrim(rtrim(el.NameElement)) and
				LTRIM(rtrim(e.ErrorParentTag))=ltrim(rtrim(el.ParentElementName))				
						inner join @t t1 on
				LTRIM(rtrim(e.ErrorFile))=t1.NameFile
	group by t1.id,e.ErrorNumber,el.id,e.ErrorValue,e.ErrorTag,e.ErrorParentTag
	-------------------------------------------------------------
	select FileNameP 'FNAME',[FileName] 'FNAME_I',
	(	select rf_idF012 'OSHIB', 
			NameElement 'IM_POL', 
			ParentElementName 'BAS_EL', 
			rf_idGuidFieldError 'ID_BAS',
			AdditionalInfo 'COMMENT'
		from vw_ErrorXSD e where e.rf_idFileNameError=fe.id FOR XML PATH('PR'),TYPE
	)
	from t_FileError f inner join t_FileNameError fe on
				f.id=fe.rf_idFileError
						inner join (select MIN(t.id) as id from @t t) t on
				fe.id=t.id
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
	----------------------------------------------------------------
	select FileNameP 'FNAME',[FileName] 'FNAME_I',
	(	select rf_idF012 'OSHIB', 
			NameElement 'IM_POL', 
			ParentElementName 'BAS_EL', 
			rf_idGuidFieldError 'ID_BAS',
			AdditionalInfo 'COMMENT'
		from vw_ErrorXSD e where e.rf_idFileNameError=fe.id FOR XML PATH('PR'),TYPE
	)
	from t_FileError f inner join t_FileNameError fe on
				f.id=fe.rf_idFileError
					   inner join (select MAX(t.id) as id from @t t) t on
				fe.id=t.id
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
	
end try
begin catch
if @@TRANCOUNT>0
    select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
go