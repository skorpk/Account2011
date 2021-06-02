use RegisterCases
go
select f.id,fb.id as idFileBack,FileNameHR,FileNameHRBack,DateRegistration,fb.DateCreate,CountSluch,r0.NumberRegister,right(RTRIM(FileNameHRBack),2)
from t_File f inner join t_FileBack fb on
		f.id=fb.rf_idFiles
		inner join t_RegisterCaseBack r0 on
		fb.id=r0.rf_idFilesBack		
where /*FileNameHR='HRM741901T34_111104'*/f.CodeM='455301'
order by FileNameHRBack,1,2,NumberRegister

declare @idFile int =1310,
		@idFileBack int =2072
declare @idMax int,
		@file varchar(30)


select @idMax=isnull(MAX(r0.rf_idFilesBack),0)
from t_FileBack f inner join t_RegisterCaseBack r0 on
		f.id=r0.rf_idFilesBack
				inner join(
								select r.ReportMonth,r.ReportYear,r.rf_idMO as ref_idF003,f.CodeM
								from t_File f inner join t_RegistersCase r on
											f.id=r.rf_idFiles
								where f.id=@idFile
							) r1 on
						f.CodeM=r1.CodeM
						--and r0.ref_idF003=r1.ref_idF003 
						and r0.ReportMonth=r1.ReportMonth
						and r0.ReportYear=r1.ReportYear
select @idMax
if @idMax!=0
begin
	select @file=(substring(FileNameHRBack,1,17)+right('0'+convert(varchar(3),cast(substring(FileNameHRBack,18,2) as tinyint)+1),2))
		--,right('0'+convert(varchar(3),cast(substring(FileNameHRBack,18,2) as tinyint)+1),2)
	from t_FileBack where id=@idMax
end
else 
begin
	select @file=(left(FileNameHR,2)+'T34_M'+left(REPLACE(SUBSTRING(FileNameHR,4,LEN(FileNameHR)),'T34_',''),10)+'01') from t_File where id=@idFile	
end
--select @file=dbo.fn_GetFileNameBack(@idFile)
select @file

update t_FileBack set FileNameHRBack='HRT34_M455301111223' where rf_idFiles=@idFile and id=@idFileBack

select * from t_FileBack where rf_idFiles=@idFile