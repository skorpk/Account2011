USE RegisterCases
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_MES_2_78]'))
DROP VIEW [dbo].vw_MES_2_78
GO
CREATE VIEW vw_MES_2_78
AS
SELECT rf_idCase
FROM dbo.t_MES mes inner join vw_sprMU mu on
        mes.MES=mu.MU 
WHERE mu.MUGroupCode=2 and mu.MUUnGroupCode=78
 GO  