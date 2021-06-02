use RegisterCases
go
IF OBJECT_ID (N'dbo.fn_GetFileNameBack', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetFileNameBack
go
CREATE FUNCTION dbo.fn_GetFileNameBack(@idFile int)
RETURNS varchar(30)
as
begin
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
						and r0.ref_idF003=r1.ref_idF003 
						and r0.ReportMonth=r1.ReportMonth
						and r0.ReportYear=r1.ReportYear

if @idMax!=0
begin
--включил такое именование реестров СП и ТК т.к эти сволочи выбрали весь диапозон имен
	select @file=(substring(FileNameHRBack,1,17)+right('00'+convert(varchar(3),cast(substring(FileNameHRBack,18,3) as tinyint)+1),3)) 
	from t_FileBack where id=@idMax
	--вспомогательная таблица в которой фиксируется имя файла. если данное имя там присутствует, то делаем рекурсивный вызов функции.
	--IF EXISTS(SELECT * FROM dbo.t_FileBackNumberOrder WHERE FILENAMEBack=@file)
	--BEGIN 
	-- SELECT @file=dbo.fn_GetFileNameBack(@idFile)
	--END		
	
end
else 
begin
	select @file=(left(FileNameHR,2)+'T34_M'+left(REPLACE(SUBSTRING(FileNameHR,4,LEN(FileNameHR)),'T34_',''),10)+'001') from t_File where id=@idFile
end
RETURN (@file)
end
go