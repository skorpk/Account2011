USE RegisterCases
GO
;WITH cte
AS(
SELECT distinct p.*,s.SMOKOD,s.OKATO AS OKAT2,cc.DateEnd
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON
            rc.id=cc.rf_idRecordCase
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack	
							INNER JOIN t_RefCasePatientDefine rf ON 
			rf.rf_idCase = recb.rf_idCase
							INNER join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
			and c.OKATO is not null
			and c.OKATO!='18000'	
							inner join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO								  		
					AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd
where rcb.ReportMonth>10 AND rcb.ReportYear=2019 AND p.rf_idSMO='34'
)
SELECT cte.rf_idRecordCaseBack FROM cte GROUP BY rf_idRecordCaseBack HAVING COUNT(*)>1

SELECT rcb.NumberRegister,rcb.PropertyNumberRegister, p.*,s.SMOKOD,s.OKATO AS OKAT2,c.OGRN_SMO,s.OGRN
FROM  t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON
            rc.id=cc.rf_idRecordCase
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack	
							INNER JOIN t_RefCasePatientDefine rf ON 
			rf.rf_idCase = recb.rf_idCase
							INNER join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
			and c.OKATO is not null
			and c.OKATO!='18000'	
							inner join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO								  		
					AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd
where rcb.ReportMonth>10 AND rcb.ReportYear=2019 AND p.rf_idSMO='34' AND p.rf_idRecordCaseBack=116782699

SELECT * from dbo.vw_sprSMOGlobal WHERE OKATO='45000' AND OGRN='1027739008440'