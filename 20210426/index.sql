USE RegisterCases
GO


;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY rf_idFile,rf_idCase,ErrorNumber ORDER BY DateRegistration) AS idrow,*
FROM t_ErrorProcessControl
)
DELETE FROM cte WHERE idrow>1

go
CREATE UNIQUE NONCLUSTERED INDEX UQ_Index_1 ON dbo.t_ErrorProcessControl(rf_idFile,rf_idCase,ErrorNumber) WITH IGNORE_DUP_KEY