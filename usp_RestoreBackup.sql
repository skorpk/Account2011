use master
go
create procedure usp_RestoreBackup
			@t nvarchar(150)
as
RESTORE DATABASE [RegisterCases] 
FROM  DISK =@t 
WITH 
MOVE 'account_primary' to 'G:\DataBase\RegisterCases\oms_accountPrimary.mdf',
MOVE 'account_registerCases' to 'G:\DataBase\RegisterCases\registerCases_data.ndf',
MOVE 'account_registerCasesInsurer' to 'G:\DataBase\RegisterCases\registerCasesInsurer_data.ndf',
MOVE 'account_registerCasesBack' to 'G:\DataBase\RegisterCases\registerCasesBack_data.ndf',
MOVE 'account_registerCasesError' to 'G:\DataBase\RegisterCases\registerCasesError_data.ndf',
MOVE 'account_log' to 'G:\DataBase\RegisterCases\registerCases_log.ldf',
MOVE 'Files' to 'G:\DataBase\RegisterCases\FileStream',
RECOVERY, FILE = 1, REPLACE,stats=5

alter database RegisterCases set MULTI_USER 
go