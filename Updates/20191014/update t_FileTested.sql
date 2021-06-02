USE  RegisterCases
go
ALTER TABLE dbo.t_FileTested ADD ReportYear AS SUBSTRING(FileName,CHARINDEX('_',FileName)+1,2)
GO
ALTER TABLE dbo.t_FileTested ADD ReportMonth AS CAST(SUBSTRING(FileName,CHARINDEX('_',FileName)+3,2) AS TINYINT)