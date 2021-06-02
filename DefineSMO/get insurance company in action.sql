USE RegisterCases
GO
declare @doc xml
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\ялн.xml',SINGLE_BLOB) HRM (ZL_LIST)


DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile INT
        
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

SELECT tf_okato,
       ogrn,
       cast(REPLACE(d_begin,'-','') AS DATE) as d_begin,
       cast(CASE when LEN(REPLACE(d_end,'-',''))=0 THEN '22220101' ELSE REPLACE(d_end,'-','') end AS DATE) AS d_end
INTO #smo
FROM OPENXML (@idoc, 'packet/insCompany/insInclude',2)
	WITH(
			tf_okato NvarCHAR(5) '../tf_okato',
			ogrn NVARCHAR(20) '../Ogrn',
			d_begin NVARCHAR(20),
			d_end NVARCHAR(20)
		)
--WHERE ogrn='1025004642519' AND tf_okato='46000'

EXEC sp_xml_removedocument @idoc
SELECT * FROM #smo
SELECT *
FROM dbo.vw_sprSMOGlobal s INNER JOIN #smo ss ON
		s.OGRN=ss.ogrn
		AND s.OKATO=ss.tf_okato
WHERE ss.d_end <>s.dateEnd AND s.dateEnd<>'22220101'
ORDER BY s.OKATO,s.OGRN
GO
DROP TABLE #smo

SELECT * FROM oms_nsi.dbo.sprSMO WHERE SMOKOD='23607'