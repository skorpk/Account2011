RESTORE DATABASE [oms_NSI] FROM  DISK = N'E:\DataBase\oms_nsi\oms_nsi.bak' 
WITH  FILE = 1,  
MOVE N'oms_nsi_db_data' TO N'E:\DataBase\oms_nsi\oms_NSI.mdf',  
MOVE N'oms_nsi_db_log' TO N'E:\DataBase\oms_nsi\oms_NSI_1.ldf',
NOUNLOAD,  STATS = 10
GO
