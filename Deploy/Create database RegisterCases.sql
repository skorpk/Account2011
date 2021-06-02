USE [master]
GO
/****** Object:  Database [oms_acount_temp]    Script Date: 09/09/2011 15:14:00 ******/
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'RegisterCases')
begin
	ALTER DATABASE RegisterCases set single_user with rollback immediate
	DROP DATABASE RegisterCases
end
GO
/****** Object:  Database [RegisterCases]    Script Date: 12/01/2011 07:25:04 ******/
CREATE DATABASE [RegisterCases] ON  PRIMARY 
( NAME = N'account_primary', FILENAME = N'F:\RegisterCases\oms_accountPrimary.mdf' , SIZE = 4072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ), 
 FILEGROUP [FileStreamGroup] CONTAINS FILESTREAM  DEFAULT 
( NAME = N'Files', FILENAME = N'F:\RegisterCases\FileStream' ), 
 FILEGROUP [RegisterCases] 
( NAME = N'account_registerCases', FILENAME = N'F:\RegisterCases\registerCases_data.ndf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ), 
 FILEGROUP [RegisterCasesBack] 
( NAME = N'account_registerCasesBack', FILENAME = N'F:\RegisterCases\registerCasesBack_data.ndf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ), 
 FILEGROUP [RegisterCasesError] 
( NAME = N'account_registerCasesError', FILENAME = N'F:\RegisterCases\registerCasesError_data.ndf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ), 
 FILEGROUP [RegisterCasesInsurer] 
( NAME = N'account_registerCasesInsurer', FILENAME = N'F:\RegisterCases\registerCasesInsurer_data.ndf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'account_log', FILENAME = N'F:\RegisterCases\registerCases_log.ldf' , SIZE = 3072KB , MAXSIZE = UNLIMITED , FILEGROWTH = 50MB)
GO

ALTER DATABASE [RegisterCases] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RegisterCases].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [RegisterCases] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [RegisterCases] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [RegisterCases] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [RegisterCases] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [RegisterCases] SET ARITHABORT OFF 
GO

ALTER DATABASE [RegisterCases] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [RegisterCases] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [RegisterCases] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [RegisterCases] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [RegisterCases] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [RegisterCases] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [RegisterCases] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [RegisterCases] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [RegisterCases] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [RegisterCases] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [RegisterCases] SET  DISABLE_BROKER 
GO

ALTER DATABASE [RegisterCases] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [RegisterCases] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [RegisterCases] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [RegisterCases] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [RegisterCases] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [RegisterCases] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [RegisterCases] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [RegisterCases] SET  READ_WRITE 
GO

ALTER DATABASE [RegisterCases] SET RECOVERY FULL 
GO

ALTER DATABASE [RegisterCases] SET  MULTI_USER 
GO

ALTER DATABASE [RegisterCases] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [RegisterCases] SET DB_CHAINING OFF 
GO


