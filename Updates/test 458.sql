USE RegisterCases
go
CREATE TABLE #t(id INT,MUSurgery VARCHAR(20),Coments VARCHAR(250), XMLNum AS (CONVERT(xml,replace(('<Root><Num num="'+Coments)+'" /></Root>',',','" /><Num num="'),0)))

INSERT #t SELECT DISTINCT 1,codeNomenclMU, '1,2,3' FROM oms_nsi.dbo.sprNomenclMUBodyParts WHERE codeNomenclMU='A16.03.022.002'
INSERT #t SELECT DISTINCT 2,codeNomenclMU, '6' FROM oms_nsi.dbo.sprNomenclMUBodyParts WHERE codeNomenclMU='A16.12.006'

SELECT MUSurgery, CAST(replace( ('<Root><Num num="'+Coments)+'" /></Root>', ',' ,'" /><Num num="') AS XML) FROM #t
;WITH cte
AS(
SELECT s.id,s.MUSurgery,m.c.value('@num[1]','smallint') AS CodeParts
FROM #t s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
SELECT id,458 FROM cte c WHERE NOT EXISTS(SELECT * FROM vw_sprNomenclBodyParts WHERE codeNomenclMU=c.MUSurgery AND code=CodeParts)
GO
DROP TABLE #t
