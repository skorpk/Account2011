use RegisterCases
go
if OBJECT_ID('usp_GetFiles',N'P') is not null
drop proc usp_GetFiles
go
--данные для формы отображающей файлы входящие
create proc usp_GetFiles
			@year smallint
as
declare @yearPrev smallint=@year-2,
		@dateReg datetime=cast(@year as char(4))+'0101',
		@dateRegEnd datetime=cast(@year as char(4))+'1231 23:59:59'


select fb.rf_idFiles,fb.id as idFileBack,fb.FileNameHRBack,fb.DateCreate,ab.NumberRegister
		,ab.PropertyNumberRegister,fb.IsUnload	
		,u.idFileBack AS IaUnreturnedAcount	
INTO #tmpBack
from t_FileBack fb inner join t_RegisterCaseBack ab on
		fb.id=ab.rf_idFilesBack	
		and ab.ReportYear >=@yearPrev
		and ab.ReportYear<=@year	
					inner JOIN (SELECT DISTINCT idFileBack from dbo.t_UnreturnedCaseInAccount) u ON
		fb.id=u.idFileBack	
WHERE fb.DateCreate>@dateReg AND fb.DateCreate<@dateRegEnd
UNION ALL
select fb.rf_idFiles,fb.id as idFileBack,fb.FileNameHRBack,fb.DateCreate,ab.NumberRegister
		,ab.PropertyNumberRegister,fb.IsUnload,NULL
from t_FileBack fb inner join t_RegisterCaseBack ab on
		fb.id=ab.rf_idFilesBack	
		and ab.ReportYear >=@yearPrev
		and ab.ReportYear<=@year														
WHERE fb.DateCreate>@dateReg AND fb.DateCreate<@dateRegEnd AND NOT EXISTS (SELECT DISTINCT idFileBack from dbo.t_UnreturnedCaseInAccount u WHERE fb.id=u.idFileBack) 

select a.id,a.idBack,a.FileNameHR,a.NumberRC,a.DateRC,a.Summa,a.CountSluch,a.FileNameHRBack,a.IsUnload,l.Namef as LPU,l.filialName,l.FilialId as CodeFilial,
		a.DateReg,a.ReportMonth as [Month],a.ReportYear as [Year],DateRegSPTK, 
		case when PropertyNumberRegister is null then '' else cast(a.NumberRC as varchar(10))+'-'+cast(PropertyNumberRegister as CHAR(1)) end NumberSPTK
		,CASE when IaUnreturnedAcount IS NULL AND a.DateReg BETWEEN DATEADD(mi,-75,GETDATE()) AND GETDATE() THEN 'Нет'
			WHEN IaUnreturnedAcount IS NULL AND a.DateReg <DATEADD(mi,-75,GETDATE()) THEN 'Да' ELSE 'Нет' END AS IaUnreturnedAcount
from (
		select f.id,fb.idFileBack as idBack,f.FileNameHR as FileNameHR,cast(a.NumberRegister as VARCHAR(6)) as NumberRC
				,a.DateRegister as DateRC,
				a.AmountPayment as Summa,f.CountSluch,rtrim(fb.FileNameHRBack) as FileNameHRBack					
				,case when isnull(fb.IsUnload,0)=0 then 'НЕТ' else 'ДА' end as IsUnload,f.CodeM
				,f.DateRegistration as DateReg
				,a.ReportMonth
				,a.ReportYear
				,fb.DateCreate as DateRegSPTK
				,fb.PropertyNumberRegister
				,fb.IaUnreturnedAcount
		from t_File f inner join dbo.t_RegistersCase a on
					f.id=a.rf_idFiles			  
					and a.ReportYear >=@yearPrev
					and a.ReportYear<=@year	--убрать комментарий
					and f.DateRegistration>@dateReg
					and f.DateRegistration<@dateRegEnd
					 left join #tmpBack fb on
					f.id=fb.rf_idFiles				
)a inner join vw_sprT001 l on
			a.CodeM=l.CodeM	
order by a.id desc

DROP TABLE #tmpBack
go


		