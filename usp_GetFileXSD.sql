use RegisterCases
go
if OBJECT_ID('usp_GetFileXSD',N'P') is not null
drop proc usp_GetFileXSD
go
create proc usp_GetFileXSD			
as
select TOP 1 WITH TIES f.DATA,f.NameFile
from dbo.t_XSD_Templates f
ORDER BY ROW_NUMBER() OVER(PARTITION BY f.NameFile ORDER BY f.DateLoad desc)		
go