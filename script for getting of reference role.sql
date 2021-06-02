USE ExchangeFinancing
GO
SET NOCOUNT ON
--SELECT 'EXEC sp_droprolemember N''db_owner'', '''+name+'''' FROM sys.database_principals WHERE type='U' AND name<>'dbo'

SELECT 'EXEC sp_addrolemember N''db_ExchangeFinancing'', '''+name+'''' FROM sys.database_principals WHERE type='U' AND name<>'dbo'