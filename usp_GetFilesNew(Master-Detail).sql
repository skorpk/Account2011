USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_GetFilesNew]    Script Date: 03/01/2012 14:53:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetFilesNew]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetFilesNew]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_GetFilesNew]    Script Date: 03/01/2012 14:53:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--данные для формы отображающей файлы входящие
create proc [dbo].[usp_GetFilesNew]
			@year smallint
as
select a.id,a.FileNameHR,a.NumberRC,a.DateRC,a.Summa,a.CountSluch,l.Namef as LPU,l.filialName,l.FilialId as CodeFilial,
		a.DateReg,a.ReportMonth as [Month],a.ReportYear as [Year]
from (
		select f.id,rtrim(f.FileNameHR) as FileNameHR,cast(a.NumberRegister as VARCHAR(6)) as NumberRC,CONVERT(CHAR(10),a.DateRegister,104) as DateRC,
					a.AmountPayment as Summa,f.CountSluch
					,convert(char(10),CAST(DateRegistration as date),104 )+' '+convert(varchar(8),CAST(DateRegistration as time(0))) as DateReg
					,a.ReportMonth
					,a.ReportYear	
					,f.CodeM				
		from t_File f inner join dbo.t_RegistersCase a on
					f.id=a.rf_idFiles			  
					and a.ReportYear=@year	--убрать комментарий					 
		group by f.id,f.FileNameHR,cast(a.NumberRegister as VARCHAR(6)),CONVERT(CHAR(10),a.DateRegister,104),
					a.AmountPayment,f.CountSluch
					,f.CodeM
					,convert(char(10),CAST(DateRegistration as date),104 )+' '+convert(varchar(8),CAST(DateRegistration as time(0))) 
					,a.ReportMonth
					,a.ReportYear
)a inner join vw_sprT001 l on
			a.CodeM=l.CodeM	
order by a.id desc

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetFilesBackNew]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetFilesBackNew]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_GetFilesBackNew]    Script Date: 03/01/2012 14:56:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--данные для формы отображающей файлы входящие
create proc [dbo].[usp_GetFilesBackNew]
			@year smallint
as
select fb.rf_idFiles, fb.FileNameHRBack
	,convert(char(10),CAST(fb.DateCreate as date),104 )+' '+convert(varchar(8),CAST(fb.DateCreate as time(0))) as DateCreate
	,case when fb.IsUnload=0 then 'нет' else 'да' end as IsUnload
from t_FileBack fb inner join t_RegisterCaseBack rb on
			fb.id=rb.rf_idFilesBack
			and rb.ReportYear=@year

GO


