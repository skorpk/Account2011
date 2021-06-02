use RegisterCases
go
if OBJECT_ID('usp_GetFileUnLoad',N'P') is not null
drop proc usp_GetFileUnLoad
go
create proc usp_GetFileUnLoad
			@num int
as
--испоьлзую выбор файлов с помощью FILESTREAM
select FileZIP.PathName(),GET_FILESTREAM_TRANSACTION_CONTEXT(),rtrim(FileNameHR) as FileNameHR
from t_File f where id=@num

go
