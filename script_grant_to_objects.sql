USE DoctorsExperts
GO
SET NOCOUNT ON
CREATE ROLE db_DoctorsExperts;

SELECT 'grant select on object::'+name+' to db_DoctorsExperts' FROM sys.objects WHERE type IN ('U','V','TF')
SELECT 'grant insert on object::'+name+' to db_DoctorsExperts' FROM sys.objects WHERE type IN ('U')
SELECT  'grant execute on object::'+name+' to db_DoctorsExperts' FROM    sys.objects WHERE   type IN('P','TT','FN','FS','FT') AND name NOT LIKE 'sp_%';
