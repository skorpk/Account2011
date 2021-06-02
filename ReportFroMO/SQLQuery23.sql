USE RegisterCases
go
DECLARE	@idFile INT=184414,
		@idFileBack INT=306497

DECLARE @countIdCase int,
		@countIdCasePR int,
		@countIdCaseE int,
		@FileNameBack varchar(26),
		@NumberSPTK varchar(15),
		@DateRegisterBack char(10),
		@countIdCaseE1 int,
		@countNotDefined INT,
		@countErroFLK smallint

select @countIdCasePR=count(distinct rc.rf_idRecordCase)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
		and f.id=@idFileBack 
		and f.rf_idFiles=@idFile 
				inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack
				INNER JOIN dbo.t_CaseBack cb ON
		rc.id=cb.rf_idRecordCaseBack              
WHERE cb.TypePay=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl e WHERE e.rf_idCase=rc.rf_idCase)
----------------------------------------------------------------------------------------------------------------------------------------------
select @countIdCase=COUNT(Distinct c.rf_idRecordCase)
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
-------------------------------количество всех ошибок---------------------------------------------------------------------------------------------------------------
select @countIdCaseE=count(distinct rc.rf_idRecordCase)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack		
					inner join dbo.t_Case rf on
		rf.id=rc.rf_idCase
					inner join dbo.t_ErrorProcessControl e on
		rf.id=e.rf_idCase
		and e.rf_idFile=@idFile
where f.id=@idFileBack and f.rf_idFiles=@idFile

select count(distinct rc.rf_idRecordCase)
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack
					inner join t_RecordCaseBack rc on
		r.id=rc.rf_idRegisterCaseBack							
					inner join dbo.t_CaseBack cb ON
        rc.id=cb.rf_idRecordCaseBack
where f.id=@idFileBack and f.rf_idFiles=@idFile AND cb.TypePay=2

--количество записей по которым не определена страхова€ принадлежность
IF NOT EXISTS(SELECT * FROM dbo.t_RegisterCaseBack WHERE rf_idFilesBack=@idFileBack AND PropertyNumberRegister=2)
BEGIN 
	;WITH cte
	AS
	(
		SELECT DISTINCT c.rf_idRecordCase
		from dbo.t_RefCasePatientDefine f INNER JOIN dbo.t_Case c ON
				f.rf_idCase=c.id  
		where f.rf_idFiles=@idFile AND f.IsUnloadIntoSP_TK IS NULL
		UNION
        select c.rf_idRecordCase
		from dbo.t_RefCasePatientDefine f INNER JOIN dbo.t_Case c ON
				f.rf_idCase=c.id  
						INNER JOIN dbo.t_RecordCaseBack rcb ON
                rcb.rf_idRecordCase= c.rf_idRecordCase
						INNER JOIN dbo.t_RegisterCaseBack rb ON
                rb.id = rcb.rf_idRegisterCaseBack
		where f.rf_idFiles=@idFile AND rb.PropertyNumberRegister=2 AND 
		NOT EXISTS(SELECT 1
					FROM t_FileBack f2 inner join t_RegisterCaseBack r2 on
							f2.id=r2.rf_idFilesBack
									INNER join t_RecordCaseBack rcc2 on
							r2.id=rcc2.rf_idRegisterCaseBack
					WHERE r2.PropertyNumberRegister=1 AND rcc2.rf_idRecordCase=rcb.rf_idRecordCase
					)
	)
	SELECT @countNotDefined=COUNT(DISTINCT cte.rf_idRecordCase) FROM cte    
	  
end  
ELSE 
BEGIN
	select @countNotDefined=count(distinct rc.rf_idRecordCase)
	from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack
						inner join t_RecordCaseBack rc on
			r.id=rc.rf_idRegisterCaseBack							
						inner join t_ErrorProcessControl e on
			rc.rf_idCase=e.rf_idCase
			and e.ErrorNumber=57
			and e.rf_idFile=@idFile										
	where f.id=@idFileBack and f.rf_idFiles=@idFile 

END

SELECT @countErroFLK=COUNT(e.rf_idGuidFieldError)
FROM dbo.t_File f INNER JOIN dbo.t_FileTested ft ON
			   f.rf_idFileTested=ft.id
					INNER JOIN dbo.t_FileError fe ON
				ft.id=fe.rf_idFileTested                  
					 inner join t_FileNameError fn on
			fe.id=fn.rf_idFileError
					INNER JOIN dbo.t_Error e ON
				fn.id=e.rf_idFileNameError
WHERE f.id=@idFile
--------------------------------------------------------------------------------------------------------------------------------------------
select rtrim(f.FileNameHR)+'.zip' as FileZIP,t001.NameS,dbo.fn_MonthName(r.ReportYear,r.ReportMonth) as ReportDate,r.ReportMonth,r.ReportYear,
		convert(CHAR(10),f.DateRegistration,104)+' '+cast(cast(f.DateRegistration as time(7)) as varchar(8)) as DateRegistration,
		f.CountSluch+@countErroFLK AS CountSluch
		,@countErroFLK as ErrorFLK
		,@countIdCase as CountIdCase
		,r.NumberRegister
		,CONVERT(char(10),r.DateRegister,104) as DateRegister
		,fe.FileNameP
		,@countIdCasePR as countIdCasePR
		,@countIdCasePR as countIdCaseNoE --количество записей без ошибок
		,@FileNameBack as FileNameBack
		,@NumberSPTK as NumberSPTK
		,@DateRegisterBack as DateRegisterBack
		,@countIdCaseE as ErrorTK1 --ошибки на “ 1	
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
