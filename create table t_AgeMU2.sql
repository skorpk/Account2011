USE RegisterCases
GO
INSERT dbo.t_AgeMU2( MU, Sex, Age )
select s.MU,Sex,t.col.value('@age','tinyint') AS Age
FROM (SELECT MU,rf_idV005 AS Sex,
			cast(replace('<Root><Age age="'+REPLACE(Age,',',';')+'" /></Root>',';','" /><Age age="') as xml) AS Age 
	  FROM oms_nsi.dbo.sprMUWithAge2) s CROSS APPLY s.Age.nodes('/Root/Age') t(col)


/*
SELECT *
FROM oms_nsi.dbo.sprMUWithAge2 WHERE Sex='Ì'

UPDATE oms_nsi.dbo.sprMUWithAge2 SET rf_idV005=1 WHERE Sex='Ì'
UPDATE oms_nsi.dbo.sprMUWithAge2 SET rf_idV005=2 WHERE Sex='Æ'
  */
--SELECT *
--FROM oms_nsi.dbo.sprMUWithAge2

--SELECT * FROM oms_nsi.dbo.sprMUWithAge

--SELECT * FROM dbo.vw_sprMUWithAge
--ALTER TABLE oms_nsi.dbo.sprMUWithAge ADD Sex CHAR(1)
