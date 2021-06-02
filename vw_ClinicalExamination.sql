USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_sprMUNotCompletedCase]    Script Date: 06/19/2013 09:09:56 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_ClinicalExamination]'))
DROP VIEW [dbo].vw_ClinicalExamination
GO
CREATE VIEW vw_ClinicalExamination
AS
SELECT rf_idCase
FROM dbo.t_MES mes inner join vw_sprMU mu on
        mes.MES=mu.MU 
           INNER JOIN (VALUES(70),(72)) m1(col1) ON
        mu.MUGroupCode=m1.col1
 GO  