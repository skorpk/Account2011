USE RegisterCases
GO
alter VIEW vw_sprCSGRules
as
SELECT k.code,k.name,d.DiagnosisCode AS DS1,d2.DiagnosisCode AS ds2,d3.DiagnosisCode AS ds3,CASE WHEN t.CodeMUtype IS NULL THEN m.CodeMU ELSE t.CodeMUtype END AS MuSurgery
	,a.Code AS Age, v5.id AS SexId,v5.Name AS Sex,l.newCode AS Los
	,CASE WHEN LEN(r.codeAdditionCriteria)=0 THEN NULL ELSE r.codeAdditionCriteria end AS rf_idAddCretiria
	,CASE when LEN(r.fraction) =0 THEN NULL ELSE r.fraction END fraction 
	,r.MSCondition
	,k.dateBeg,k.dateEnd
FROM oms_NSI.dbo.tCSGroup k INNER JOIN oms_NSI.dbo.tCSGRuleRelation rg ON
			k.CSGroupId=rg.rf_CSGroupId
					INNER JOIN oms_NSI.dbo.tCSGRule r ON
            rg.rf_CSGRuleId=r.CSGRuleId
					LEFT JOIN oms_NSI.dbo.tCSGDiagnosisGroup gd ON
            r.rf_CSGDiagnosisGroupId=gd.CSGDiagnosisGroupId
					LEFT JOIN oms_NSI.dbo.tCSGDiagnosis d ON
             gd.CSGDiagnosisGroupId=d.rf_CSGDiagnosisGroupId					
					LEFT JOIN oms_NSI.dbo.sprNomenclMUtype t ON
			r.rf_NomenclMUTypeId=t.rf_nomenclMUId
					LEFT JOIN oms_NSI.dbo.sprNomenclMU m ON
			r.rf_NomenclMUId=m.nomenclMUId
			---------DS2-----------------
			LEFT JOIN oms_NSI.dbo.tCSGDiagnosisGroup gd2 ON
            r.rf_CSGDiagnosisGroupId_sop=gd2.CSGDiagnosisGroupId
					LEFT JOIN oms_NSI.dbo.tCSGDiagnosis d2 ON
             gd2.CSGDiagnosisGroupId=d2.rf_CSGDiagnosisGroupId					
			 ---------DS3-----------------
			LEFT JOIN oms_NSI.dbo.tCSGDiagnosisGroup gd3 ON
            r.rf_CSGDiagnosisGroupId_osl=gd3.CSGDiagnosisGroupId
					LEFT JOIN oms_NSI.dbo.tCSGDiagnosis d3 ON
             gd3.CSGDiagnosisGroupId=d3.rf_CSGDiagnosisGroupId	
			 -------Age-----------------
					LEFT JOIN oms_NSI.dbo.tCSGAge a ON
			r.rf_CSGAgeId=a.CSGAgeId	
			--------Los------------------
					LEFT JOIN oms_NSI.dbo.tCSGLos l ON
			r.rf_CSGLosId=l.CSGLosId		
			-------Sex------------
					LEFT JOIN oms_NSI.dbo.sprV005 v5 ON
            r.rf_sprV005Id=v5.Id
WHERE k.dateBeg>='20210101' AND k.dateEnd<'20220101' --AND d.DiagnosisCode='O10.1' AND r.MSCondition=1