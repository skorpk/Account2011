alter database AccountOMS set single_user with rollback immediate
go
RESTORE DATABASE [AccountOMS] FROM  DISK = N'k:\AccountOMS\Full\AccountOMS_3_1_2012_12_50.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 10
GO
alter database AccountOMS set multi_user 
