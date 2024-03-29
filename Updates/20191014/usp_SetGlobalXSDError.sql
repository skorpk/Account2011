USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_SetGlobalXSDError]    Script Date: 14.10.2019 11:59:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_SetGlobalXSDError]
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
	IF EXISTS(SELECT 1 FROM dbo.t_FileTested WHERE ReportMonth>10 AND ReportYear>'18')	
	BEGIN 
		select FileNameP 'FNAME',[FileName] 'FNAME_I',CAST(GETDATE() AS DATE) AS DATE_F,
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
		select FileNameP 'FNAME',[FileName] 'FNAME_I',CAST(GETDATE() AS DATE) AS DATE_F,
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
	end	
	ELSE 
	BEGIN
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
	end  
end try
begin catch
if @@TRANCOUNT>0
    select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
