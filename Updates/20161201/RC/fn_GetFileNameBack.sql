USE [RegisterCases]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetFileNameBack]    Script Date: 30.01.2017 8:06:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[fn_GetFileNameBack](@idFile int)
RETURNS varchar(30)
as
begin
declare @idMax int,
		@file varchar(30), 
		@typeFile CHAR(1)

SELECT @typeFile=TypeFile FROM dbo.t_File WHERE id=@idFile

select @idMax=isnull(MAX(r0.rf_idFilesBack),0)
from t_FileBack f inner join t_RegisterCaseBack r0 on
		f.id=r0.rf_idFilesBack
				INNER JOIN t_File f1 ON
		f.rf_idFiles=f1.id  
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
WHERE f1.TypeFile=@typeFile

if @idMax!=0
begin
--включил такое именование реестров СП и ТК 
	select @file=(REPLACE(substring(FileNameHRBack,1,17),'H',@typeFile)+right('0000'+convert(varchar(5),cast(substring(FileNameHRBack,18,5) as SMALLINT)+1),5)) 
	--from t_FileBack where id=@idMax	
	from t_FileBack fb INNER JOIN t_File f ON
			fb.rf_idFiles=f.id  
	where fb.id=@idMax	AND TypeFile=@typeFile
	
end
else 
begin
	select @file=(REPLACE(left(FileNameHR,2),'H',@typeFile)+'T34_M'+left(REPLACE(SUBSTRING(FileNameHR,4,LEN(FileNameHR)),'T34_',''),10)+'00001') from t_File where id=@idFile AND TypeFile=@typeFile
end
RETURN (@file)
end

GO


