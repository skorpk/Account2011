USE RegisterCases
GO
ALTER TABLE dbo.t_File DROP column FileZIP
GO
ALTER TABLE dbo.t_File SET (FILESTREAM_ON="NULL")
GO
ALTER Database RegisterCases REMOVE FILE Files
GO
ALTER Database RegisterCases REMOVE FILEGROUP FileStreamGROUP
