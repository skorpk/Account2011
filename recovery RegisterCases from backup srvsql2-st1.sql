USE [master]
RESTORE DATABASE [RegisterCases] FROM  DISK = N'O:\Backups\RegisterCases\\RegisterCases_4_9_2019.bak' WITH  FILE = 1,  
MOVE N'account_primary' TO N'F:\RegisterCases\oms_accountPrimary.mdf',  
MOVE N'account_registerCases' TO N'F:\RegisterCases\registerCases_data.ndf',  
MOVE N'account_registerCasesBack' TO N'g:\RegisterCases\registerCasesBack_data.ndf',  
MOVE N'account_registerCasesError' TO N'f:\RegisterCases\registerCasesError_data.ndf',  
MOVE N'account_registerCasesInsurer' TO N'G:\RegisterCases\registerCasesInsurer_data.ndf',  
MOVE N'account_registerCasesInsurer2' TO N'G:\RegisterCases\account_registerCasesInsurer_2.ndf',  
MOVE N'account_log' TO N'G:\RegisterCases\registerCases_log.ldf',  MOVE N'Files' TO N'G:\RegisterCases\FileStream',  RECOVERY,  STATS = 5

GO


