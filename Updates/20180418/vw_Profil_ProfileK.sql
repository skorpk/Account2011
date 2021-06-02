USE RegisterCases
GO
CREATE VIEW vw_Profil_ProfileK
as
SELECT B.code as Profil_K,
       C.Id as Profil,
       A.dateBeg,
       A.dateEnd
FROM oms_nsi.dbo.sprV020MP A
     inner join oms_nsi.dbo.sprV020 B on A.rf_sprV020Id = B.sprV020Id
     inner join oms_nsi.dbo.sprV002 C on A.rf_sprV002UId = C.[UId]
	 go
GRANT SELECT ON  vw_Profil_ProfileK TO db_RegisterCase
