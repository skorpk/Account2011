USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_SetGlobalError]    Script Date: 14.10.2019 11:59:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_SetGlobalError]
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
	IF EXISTS(SELECT 1 FROM dbo.t_FileTested WHERE ReportMonth>10 AND ReportYear>'18')	
	BEGIN 
		select FileNameP 'FNAME', [FileName] 'FNAME_I',CAST(GETDATE() AS DATE) AS DATE_F, ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
		from vw_GlobalError
		where id=@idFileTest and id1=@t1	
		FOR XML PATH(''),TYPE,ROOT('FLK_P')
	
		select FileNameP 'FNAME', [FileName] 'FNAME_I',CAST(GETDATE() AS DATE) AS DATE_F, ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
		from vw_GlobalError
		where id=@idFileTest and id1=@t2	
		FOR XML PATH(''),TYPE,ROOT('FLK_P')
	END
	ELSE
	BEGIN
		select FileNameP 'FNAME', [FileName] 'FNAME_I', ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
		from vw_GlobalError
		where id=@idFileTest and id1=@t1	
		FOR XML PATH(''),TYPE,ROOT('FLK_P')
	
		select FileNameP 'FNAME', [FileName] 'FNAME_I', ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
		from vw_GlobalError
		where id=@idFileTest and id1=@t2	
		FOR XML PATH(''),TYPE,ROOT('FLK_P')  
	END  
		
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
