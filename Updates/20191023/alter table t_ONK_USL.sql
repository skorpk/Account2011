USE AccountOMS
GO
--ALTER TABLE dbo.t_ONK_USL DROP COLUMN id
--go
--ALTER TABLE dbo.t_DrugTherapy DROP COLUMN rf_idONK_USL
--GO
/*--------------------------------------------------------------------------------*/
--ALTER TABLE dbo.t_ONK_USL ADD id TINYINT 
GO
;WITH cte
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY rf_idCase,rf_idN013 ORDER BY rf_idN013) AS id,rf_idCase,rf_idN013
	FROM t_Case c INNER JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase
	WHERE c.DateEnd>'20181231' AND u.id IS null
)
UPDATE u SET id=c.id
FROM dbo.t_ONK_USL u INNER JOIN cte C ON
		u.rf_idCase=c.rf_idCase
		AND C.rf_idN013 = u.rf_idN013
GO
--ALTER TABLE dbo.t_ONK_USL ALTER COLUMN id TINYINT NOT null
--GO
--ALTER TABLE dbo.t_DrugTherapy ADD rf_idONK_USL TINYINT
GO
BEGIN TRANSACTION
UPDATE d SET d.rf_idONK_USL=u.id
FROM dbo.t_ONK_USL u INNER JOIN dbo.t_DrugTherapy d ON
		d.rf_idCase = u.rf_idCase
		AND d.rf_idN013 = u.rf_idN013
WHERE u.id IS NOT null 
commit