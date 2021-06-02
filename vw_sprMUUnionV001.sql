USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprMUUnionV001]'))
DROP VIEW dbo.vw_sprMUUnionV001
GO
CREATE VIEW vw_sprMUUnionV001
AS 
SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=55 AND MUUnGroupCode=1
UNION ALL
SELECT IDRB FROM OMS_NSI.dbo.V001
go
