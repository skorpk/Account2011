USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprCSGSurgery]'))
DROP VIEW dbo.vw_sprCSGSurgery
GO
CREATE VIEW vw_sprCSGSurgery
AS
--SELECT tCSG.CSGroupId, tCSG.code, tCSG.name,tCSG.rf_CSGTypeId,mu.CodeMU,mu.NameMU
--FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGNomenclMU t1 ON
--				tCSG.CSGroupId=t1.rf_CSGroupId
--							INNER JOIN oms_NSI.dbo.sprNomenclMU mu ON
--				t1.rf_NomenclMUId=mu.rf_nomenclMUGroupId
--WHERE rf_CSGTypeId=2--хирург.КСГ

SELECT    A.CSGroupId AS CSGroupId, A.code,A.tfomsName AS name, A.rf_CSGTypeId AS rf_CSGTypeId, 
        ISNULL(D.CodeMUtype,C.CodeMU) AS CodeMU, 
        ISNULL(D.NameMUtype,C.NameMU) AS NameMU   
FROM    oms_NSI.dbo.tCSGroup A INNER JOIN oms_NSI.dbo.tCSGNomenclMU B ON 
				A.CSGroupId = B.rf_CSGroupId 
					LEFT OUTER JOIN oms_NSI.dbo.sprNomenclMU C 
            ON B.rf_NomenclMUId = C.nomenclMUId 
        LEFT OUTER JOIN oms_NSI.dbo.sprNomenclMUtype D 
            ON B.rf_NomenclMUTypeId = D.nomenclMUtypeId

GO