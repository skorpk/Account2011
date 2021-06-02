USE RegisterCases
GO
CREATE VIEW vw_sprV019_2021
as
SELECT v19.Code AS IDHM,v19.NAME,v18.Code AS IDHVID,v19.DateBeg AS DateBeg19, v19.DateEnd AS DateEnd19,v18.DateBeg AS DateBeg18, v19.DateEnd AS DateEnd18,m.DateBeg AS DateBeg22, m.DateEnd AS DateEnd22
FROM OMS_NSI.dbo.sprV019 v19 INNER JOIN OMS_NSI.dbo.sprV022 m ON
			v19.rf_sprV022Id=m.sprV022Id
							INNER JOIN OMS_NSI.dbo.sprV018 v18 ON
			v19.rf_sprV018Id=v18.SprV018Id
							INNER JOIN oms_nsi.dbo.sprV019V018V022Relation v ON
            v18.SprV018Id=v.rf_sprV018Id
			AND v.rf_sprV022Id=m.sprV022Id
WHERE v19.DateBeg>='20210101'
GO
GRANT SELECT ON dbo.vw_sprV019_2021 TO db_RegisterCase
