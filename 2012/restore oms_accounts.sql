ALTER DATABASE oms_accounts set single_user with rollback immediate
go
RESTORE DATABASE [oms_accounts] FROM  DISK = N'k:\oms_accounts\Data\oms_accounts_1_1_2012.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 10
GO
ALTER DATABASE oms_accounts set multi_user 

GO
