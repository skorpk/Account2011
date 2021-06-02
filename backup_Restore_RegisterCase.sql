---------------------------BACKUP------------------------------------------------------
/*
BACKUP DATABASE [RegisterCases] 
TO  DISK = N'E:\Backup\RegisterCase\RegisterCase_20111215_1.bak' 
WITH NOFORMAT, INIT,  
NAME = N'Babenko_Ivanov_Kardio', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
*/
---------------------------RESTORE----------------------------------------------------
use master
go
alter database RegisterCases set SINGLE_USER with rollback immediate
go
RESTORE DATABASE [RegisterCases] FROM  DISK = N'E:\Backup\RegisterCase\RegisterCase_20111215.bak' WITH  FILE = 1,  NOUNLOAD, REPLACE, STATS = 10
GO
alter database RegisterCases set MULTI_USER
go
use PolicyRegister
go
delete from ZP1LOG where ID>85
