USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_FillBackTables]    Script Date: 02/21/2012 11:12:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_FillBackTables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_FillBackTables]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_FillBackTables]    Script Date: 02/21/2012 11:12:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[usp_FillBackTables]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int,
			@property tinyint	
as
declare @fileName varchar(29),
		@idFileBack int,
		@idRegisterCaseBack int
declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

--имя реестра СП и ТК
select @fileName=dbo.fn_GetFileNameBack(@idFile)

--select @fileName=left(FileNameHR,2)+'T34_M'+REPLACE(SUBSTRING(FileNameHR,4,LEN(FileNameHR)),'T34_','') from t_File where id=@idFile

begin transaction
begin try
	--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
	update t_RefCasePatientDefine
	set IsUnloadIntoSP_TK=1
	from t_RefCasePatientDefine rf inner join @CaseDefined cd on
				rf.rf_idCase=cd.rf_idCase and
				rf.rf_idRegisterPatient=cd.ID_Patient


 insert t_FileBack(rf_idFiles,FileNameHRBack) values(@idFile,@fileName)
 select @idFileBack=SCOPE_IDENTITY()
 
 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
 from t_RegistersCase c
 where c.rf_idFiles=@idFile
 select @idRegisterCaseBack=SCOPE_IDENTITY()
 
 
 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
	output inserted.id,inserted.rf_idCase into @idRecordCaseBack
 select c.rf_idRecordCase,@idRegisterCaseBack,c.id
 from @CaseDefined cd inner join t_Case c on
		cd.rf_idCase=c.id

--изменения от 20.01.2012
 insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
 select rcb.rf_idRecordCaseBack,c.rf_idF008,case when c.rf_idF008=3 then null else c.SPolicy end as SPolicy
		,case when c.rf_idF008=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolicy
		,c.SMO
		,18000
 from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefine c on
			rf.id=c.rf_idRefCaseIteration
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
			
 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
 from @CaseDefined cd inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
					  left join t_ErrorProcessControl e on
			cd.rf_idCase=e.rf_idCase and
			e.rf_idFile=@idFile
--возвращаем id файла реестра СП и ТК
	select @idFileBack
 

end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction

GO

