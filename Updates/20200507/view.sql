USE RegisterCases
GO
alter VIEW vw_sprMGI_N010_N012
as
SELECT TOP 1000 cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU, n10.ID_Igh AS Diag_Code, n10.KOD_Igh,n12.DS_Igh,n12.DATEBEG,n12.DATEEND
FROM oms_nsi.dbo.vw_sprMU m INNER JOIN oms_nsi.dbo.sprMUN010 mm ON
		m.MUId=mm.rf_MUId
				INNER JOIN oms_nsi.dbo.sprN010 n10 ON
        mm.rf_sprN010Id=n10.sprN010Id
				INNER JOIN oms_nsi.dbo.sprN012 n12 ON
        n10.ID_Igh=n12.ID_Igh
ORDER BY mu
GO
GRANT SELECT ON vw_sprMGI_N010_N012 TO db_RegisterCase

