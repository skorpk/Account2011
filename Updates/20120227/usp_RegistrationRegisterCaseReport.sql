USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_RegistrationRegisterCaseReport]    Script Date: 02/27/2012 09:59:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RegistrationRegisterCaseReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_RegistrationRegisterCaseReport]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_RegistrationRegisterCaseReport]    Script Date: 02/27/2012 09:59:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[usp_RegistrationRegisterCaseReport]
				@idFile int,
				@idFileBack int
as
SET LANGUAGE russian
declare @countIdCase int,
		@countIdCasePR int,
		@countIdCaseE int,
		@FileNameBack varchar(26),
		@NumberSPTK varchar(15),
		@DateRegisterBack char(10)


--select @countIdCasePR=COUNT(cd.rf_idRefCaseIteration) 
--from t_RefCasePatientDefine rf inner join t_CaseDefine cd on
--			rf.id=cd.rf_idRefCaseIteration
--where rf.rf_idFiles=@idFile 
select @countIdCasePR=count(distinct rf.id)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack
					inner join t_RefCasePatientDefine rf on
		rf.rf_idCase=rc.rf_idCase
					inner join t_CasePatientDefineIteration i on
		rf.id=i.rf_idRefCaseIteration
		and i.rf_idIteration=1		
where f.id=@idFileBack and f.rf_idFiles=@idFile 
if @countIdCasePR=0
begin
	select @countIdCasePR=count(distinct rf.id)
	from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack
						inner join t_RecordCaseBack rc on
			r.id=rc.rf_idRegisterCaseBack
						inner join t_RefCasePatientDefine rf on
			rf.rf_idCase=rc.rf_idCase
						inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration	
			and i.rf_idIteration in (2,3,4)	
	where f.id=@idFileBack and f.rf_idFiles=@idFile 
end
--------------------------------------------------------------------------------------------------------------------------------------------
select @countIdCase=COUNT(Distinct c.id)
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
				  inner join t_RecordCase rc on
			r.id=rc.rf_idRegistersCase
				  inner join t_Case c on
			rc.id=c.rf_idRecordCase				  
where f.id=@idFile	
--------------------------------------------------------------------------------------------------------------------------------------------
select @FileNameBack=FileNameHRBack,@DateRegisterBack=CONVERT(char(10),r.DateCreate,104),
		@NumberSPTK=CAST(NumberRegister as varchar(8))+'-'+CAST(PropertyNumberRegister as varchar(3))
from t_FileBack fb inner join t_RegisterCaseBack r on
		fb.id=r.rf_idFilesBack
where rf_idFiles=@idFile and fb.id=@idFileBack
----------------------------------------------------------------------------------------------------------------------------------------------
--select @countIdCaseNoE=COUNT(distinct rf_idCase) from t_ErrorProcessControl where rf_idFile=@idFile
declare @iteration tinyint

select @iteration=PropertyNumberRegister from t_RegisterCaseBack where rf_idFilesBack=@idFile
if(@iteration=0 or @iteration=1)
begin
select @countIdCaseE=count(distinct rc.id)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack		
					inner join t_ErrorProcessControl e on
		rc.rf_idCase=e.rf_idCase
where f.id=@idFileBack and f.rf_idFiles=@idFile
end
else
begin
	select @countIdCaseE=count(distinct rf.id)
	from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack
						inner join t_RecordCaseBack rc on
			r.id=rc.rf_idRegisterCaseBack
						inner join t_RefCasePatientDefine rf on
			rf.rf_idCase=rc.rf_idCase
						inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration	
			and i.rf_idIteration in (2,3,4)	
						inner join t_ErrorProcessControl e on
		rf.rf_idCase=e.rf_idCase
	where f.id=@idFileBack and f.rf_idFiles=@idFile 
end
--------------------------------------------------------------------------------------------------------------------------------------------
select rtrim(f.FileNameHR)+'.zip' as FileZIP,t001.NameS,dbo.fn_MonthName(r.ReportYear,r.ReportMonth) as ReportDate,r.ReportMonth,r.ReportYear,
		convert(CHAR(10),f.DateRegistration,104)+' '+cast(cast(f.DateRegistration as time(7)) as varchar(8)) as DateRegistration,
		f.CountSluch,(f.CountSluch-@countIdCase) as ErrorFLK
		,@countIdCase as CountIdCase
		,r.NumberRegister
		,CONVERT(char(10),r.DateRegister,104) as DateRegister
		,fe.FileNameP
		,@countIdCasePR as countIdCasePR
		,@countIdCasePR-@countIdCaseE as countIdCaseNoE
		,@FileNameBack as FileNameBack
		,@NumberSPTK as NumberSPTK
		,@DateRegisterBack as DateRegisterBack		
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
			  inner join vw_sprT001 t001 on
		f.CodeM=t001.CodeM
				inner join t_FileTested ft on
		f.rf_idFileTested=ft.id
				left join t_FileError fe on
		ft.id=fe.rf_idFileTested
where f.id=@idFile

GO

