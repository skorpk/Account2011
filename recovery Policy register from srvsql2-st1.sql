USE [master]
RESTORE DATABASE [PolicyRegister] FROM  DISK = N'G:\Backups\PolicyRegister_2_4_2018.bak' WITH  FILE = 1, 
MOVE N'srz3_00_Data' TO N'i:\PolicyRegister\PolicyRegister.MDF',  
MOVE N'srz3_00_Log' TO N'i:\PolicyRegister\PolicyRegister.LDF',  NOUNLOAD,  STATS = 5

GO


