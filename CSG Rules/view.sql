USE oms_NSI
GO
SELECT k.code,k.name,d.DiagnosisCode AS DS1,d2.DiagnosisCode AS ds2,d3.DiagnosisCode AS ds3,CASE WHEN t.CodeMUtype IS NULL THEN m.CodeMU ELSE t.CodeMUtype END asMuSurgery
	,a.Code AS Age, v5.id AS SexId,v5.Name AS Sex,l.newCode AS Los,r.codeAdditionCriteria, r.fraction,r.MSCondition
	,k.dateBeg,k.dateEnd
FROM dbo.tCSGroup k INNER JOIN dbo.tCSGRuleRelation rg ON
			k.CSGroupId=rg.rf_CSGroupId
					INNER JOIN dbo.tCSGRule r ON
            rg.rf_CSGRuleId=r.CSGRuleId
					LEFT JOIN dbo.tCSGDiagnosisGroup gd ON
            r.rf_CSGDiagnosisGroupId=gd.CSGDiagnosisGroupId
					LEFT JOIN dbo.tCSGDiagnosis d ON
             gd.CSGDiagnosisGroupId=d.rf_CSGDiagnosisGroupId					
					LEFT JOIN dbo.sprNomenclMUtype t ON
			r.rf_NomenclMUTypeId=t.rf_nomenclMUId
					LEFT JOIN dbo.sprNomenclMU m ON
			r.rf_NomenclMUId=m.nomenclMUId
			---------DS2-----------------
			LEFT JOIN dbo.tCSGDiagnosisGroup gd2 ON
            r.rf_CSGDiagnosisGroupId_sop=gd2.CSGDiagnosisGroupId
					LEFT JOIN dbo.tCSGDiagnosis d2 ON
             gd2.CSGDiagnosisGroupId=d2.rf_CSGDiagnosisGroupId					
			 ---------DS3-----------------
			LEFT JOIN dbo.tCSGDiagnosisGroup gd3 ON
            r.rf_CSGDiagnosisGroupId_osl=gd3.CSGDiagnosisGroupId
					LEFT JOIN dbo.tCSGDiagnosis d3 ON
             gd3.CSGDiagnosisGroupId=d3.rf_CSGDiagnosisGroupId	
			 -------Age-----------------
					LEFT JOIN dbo.tCSGAge a ON
			r.rf_CSGAgeId=a.CSGAgeId	
			--------Los------------------
					LEFT JOIN dbo.tCSGLos l ON
			r.rf_CSGLosId=l.CSGLosId		
			-------Sex------------
					LEFT JOIN dbo.sprV005 v5 ON
            r.rf_sprV005Id=v5.Id
WHERE k.dateBeg>='20210101' AND k.dateEnd<'20220101' 