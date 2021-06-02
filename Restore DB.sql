use master
go
RESTORE FILELISTONLY FROM  DISK = N'E:\Backup\RegisterCase\test.bak' 
go
RESTORE DATABASE Test 
FROM  DISK = N'E:\Backup\RegisterCase\test.bak' 
WITH 
MOVE 'account_primary' to 'G:\DataBase\Test\oms_accountPrimary.mdf',
MOVE 'account_registerCases' to 'G:\DataBase\Test\registerCases_data.ndf',
MOVE 'account_registerCasesInsurer' to 'G:\DataBase\test\registerCasesInsurer_data.ndf',
MOVE 'account_registerCasesBack' to 'G:\DataBase\test\registerCasesBack_data.ndf',
MOVE 'account_registerCasesError' to 'G:\DataBase\test\registerCasesError_data.ndf',
MOVE 'account_log' to 'G:\DataBase\test\registerCases_log.ldf',
MOVE 'Files' to 'G:\DataBase\test\FileStream',
RECOVERY, FILE = 1
GO




