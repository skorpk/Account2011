use master
go
--RESTORE FILELISTONLY FROM  DISK = N'J:\AccountOMS\AccountOMS_2_1_2016.bak' 
--go
--alter database AccountOMS set SINGLE_USER with rollback immediate
--go
--USE [master]
--GO
--/****** Object:  Database [AccountOMS]    Script Date: 01/27/2014 14:23:42 ******/
--DROP DATABASE [AccountOMS]
--GO

RESTORE DATABASE [AccountOMS] 
FROM  DISK = N'o:\DB\AccountOMS_1_3_2019.bak' 
WITH 
MOVE 'account_primary' to 'H:\AccountOMS\AccountsOMS_data.mdf',
MOVE 'AccountOMS_Case' to 'H:\AccountOMS\AccountOMSCases_data.ndf',
MOVE 'accountOMS_Insurer' to 'J:\AccountOMS\AccountOMSInsurer_data.ndf',
MOVE 'FG2011' to 'J:\AccountOMS\AccountMU.ndf',
MOVE 'account_log' to 'J:\AccountOMS\AccountsOMS_log.ldf',
MOVE 'Files' to 'J:\AccountOMS\FileStream',
RECOVERY, STATS=3 
GO
--alter database AccountOMS set MULTI_USER 