declare @idFile int=15
SET LANGUAGE russian
declare @countIdCase int,
		@countIdCasePR int,
		@countIdCaseNoE int,
		@FileNameBack varchar(26),
		@NumberSPTK varchar(15),
		@DateRegisterBack char(10)

select @countIdCasePR=COUNT(cd.rf_idRefCaseIteration) 
from t_RefCasePatientDefine rf inner join t_CaseDefine cd on
			rf.id=cd.rf_idRefCaseIteration
where rf.rf_idFiles=@idFile


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
where rf_idFiles=@idFile
----------------------------------------------------------------------------------------------------------------------------------------------
select @countIdCaseNoE=COUNT(*) from t_ErrorProcessControl where rf_idFile=@idFile

select @countIdCase,@countIdCasePR-@countIdCaseNoE


--------------------------------------------------------------------------------------------------------------------------------------------
select rtrim(f.FileNameHR)+'.zip' as FileZIP,t001.NameS,dbo.fn_MonthName(r.ReportYear,r.ReportMonth) as ReportDate,r.ReportMonth,r.ReportYear,
		convert(CHAR(10),f.DateRegistration,104)+' '+cast(cast(f.DateRegistration as time(7)) as varchar(8)) as DateRegistration,
		f.CountSluch,(f.CountSluch-@countIdCase) as ErrorFLK
		,@countIdCase as CountIdCase
		,r.NumberRegister
		,CONVERT(char(10),r.DateRegister,104) as DateRegister
		,fe.FileNameP
		,@countIdCasePR as countIdCasePR
		,@countIdCasePR-@countIdCaseNoE as countIdCaseNoE
		,@FileNameBack as FileNameBack
		,@NumberSPTK as NumberSPTK
		,@DateRegisterBack as DateRegisterBack		
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
			  inner join vw_sprT001 t001 on
		r.rf_idMO=t001.mcod
				inner join t_FileTested ft on
		f.rf_idFileTested=ft.id
				inner join t_FileError fe on
		ft.id=fe.rf_idFileTested
where f.id=@idFile