use RegisterCases
go
if OBJECT_ID('usp_RegistrationRegisterCaseReport',N'P') is not null
drop proc usp_RegistrationRegisterCaseReport
go
create procedure usp_RegistrationRegisterCaseReport
				@idFile int,
				@idFileBack int
as
SET LANGUAGE russian
declare @countIdCase int,
		@countIdCasePR int,
		@countIdCaseE int,
		@FileNameBack varchar(26),
		@NumberSPTK varchar(15),
		@DateRegisterBack char(10),
		@countIdCaseE1 int,
		@countNotDefined int

select @countIdCasePR=count(distinct rf.rf_idCase)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
		and f.id=@idFileBack 
		and f.rf_idFiles=@idFile 
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack
					inner join t_RefCasePatientDefine rf on
		rf.rf_idCase=rc.rf_idCase
					left join t_ErrorProcessControl e on
		rf.rf_idCase=e.rf_idCase
		and e.ErrorNumber=57
		and e.rf_idFile=@idFile
where e.rf_idCase is null 
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
select @countIdCaseE=count(distinct rc.id)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack		
					inner join t_RefCasePatientDefine rf on
		rf.rf_idCase=rc.rf_idCase
					inner join (select distinct e1.*
								from t_ErrorProcessControl e1 left join (select * 
																		 from t_ErrorProcessControl 
																		 where rf_idFile=@idFile and ErrorNumber=57) e2 on
											e1.rf_idCase=e2.rf_idCase
											and e1.rf_idFile=e2.rf_idFile			 			
								where e1.rf_idFile=@idFile and e2.rf_idCase is null
								) e on
		rf.rf_idCase=e.rf_idCase
		and e.ErrorNumber!=57
		and e.rf_idFile=@idFile
where f.id=@idFileBack and f.rf_idFiles=@idFile

--количество записей по которым не определена страхова€ принадлежность
select @countNotDefined=count(distinct rc.id)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack		
					inner join t_RefCasePatientDefine rf on
		rf.rf_idCase=rc.rf_idCase
					inner join t_ErrorProcessControl e on
		rf.rf_idCase=e.rf_idCase
		and e.ErrorNumber=57
		and e.rf_idFile=@idFile
where f.id=@idFileBack and f.rf_idFiles=@idFile


select @countIdCaseE1=count(distinct rc.id)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack							
					inner join t_ErrorProcessControl e on
		rc.rf_idCase=e.rf_idCase
		and e.ErrorNumber!=57
		and e.rf_idFile=@idFile
					left join t_RefCasePatientDefine rf on
		rf.rf_idCase=rc.rf_idCase						
where f.id=@idFileBack and f.rf_idFiles=@idFile and rf.id is null
--------------------------------------------------------------------------------------------------------------------------------------------
select rtrim(f.FileNameHR)+'.zip' as FileZIP,t001.NameS,dbo.fn_MonthName(r.ReportYear,r.ReportMonth) as ReportDate,r.ReportMonth,r.ReportYear,
		convert(CHAR(10),f.DateRegistration,104)+' '+cast(cast(f.DateRegistration as time(7)) as varchar(8)) as DateRegistration,
		f.CountSluch
		,(f.CountSluch-@countIdCase) as ErrorFLK
		,@countIdCase as CountIdCase
		,r.NumberRegister
		,CONVERT(char(10),r.DateRegister,104) as DateRegister
		,fe.FileNameP
		,@countIdCasePR as countIdCasePR
		,@countIdCasePR-@countIdCaseE as countIdCaseNoE --количество записей без ошибок
		,@FileNameBack as FileNameBack
		,@NumberSPTK as NumberSPTK
		,@DateRegisterBack as DateRegisterBack
		,@countIdCaseE1 as ErrorTK1 --ошибки на “ 1	
		,@countNotDefined as UnDefined
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
			  inner join vw_sprT001 t001 on
		f.CodeM=t001.CodeM
				inner join t_FileTested ft on
		f.rf_idFileTested=ft.id
				left join t_FileError fe on
		ft.id=fe.rf_idFileTested
where f.id=@idFile
go