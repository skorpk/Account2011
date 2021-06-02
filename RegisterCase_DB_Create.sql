USE [master]
GO

/****** Object:  Database [oms_acount_temp]    Script Date: 09/09/2011 15:14:00 ******/
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'RegisterCases')
ALTER DATABASE RegisterCases set single_user with rollback immediate
DROP DATABASE [RegisterCases]
GO

USE [master]
GO

CREATE DATABASE RegisterCases 
---------для таблиц содержащие данные из реестров случаев оказания мед.помощи.
ON  PRIMARY 
( 
	NAME = N'account_primary', 
	FILENAME = N'G:\DataBase\RegisterCases\oms_accountPrimary.mdf' , 
	SIZE = 4072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
FILEGROUP RegisterCases
( 
	NAME = N'account_registerCases', 
	FILENAME = N'G:\DataBase\RegisterCases\registerCases_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
FILEGROUP RegisterCasesInsurer
( 
	NAME = N'account_registerCasesInsurer', 
	FILENAME = N'G:\DataBase\RegisterCases\registerCasesInsurer_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
--реестры СП и ТК
FILEGROUP RegisterCasesBack
( 
	NAME = N'account_registerCasesBack', 
	FILENAME = N'G:\DataBase\RegisterCases\registerCasesBack_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
---для таблиц с ошибками
FILEGROUP RegisterCasesError
( 
	NAME = N'account_registerCasesError', 
	FILENAME = N'G:\DataBase\RegisterCases\registerCasesError_data.ndf' , 
	SIZE = 3072KB , MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
--хранит файлы реестров случаев
 FILEGROUP FileStreamGroup CONTAINS FILESTREAM( NAME = Files,FILENAME = 'G:\DataBase\RegisterCases\FileStream')
 LOG ON 
( 
	NAME = N'account_log', 
	FILENAME = N'G:\DataBase\RegisterCases\registerCases_log.ldf' , 
	SIZE = 1024KB , MAXSIZE = 2048GB , 
	FILEGROWTH = 10%
)
GO
ALTER DATABASE RegisterCases SET COMPATIBILITY_LEVEL = 100
GO