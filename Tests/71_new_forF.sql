USE RegisterCases
GO
DECLARE @CaseDefined TVP_CasePatient ,		
		@idFile int	=99767


--select @idFile=f.id from t_File f WHERE f.TypeFile='F' AND f.DateRegistration>'20170201' AND f.DateRegistration<'20170810' ORDER BY NEWID()

SELECT * FROM dbo.vw_getFileBack WHERE rf_idFiles=@idFile					   

	
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

INSERT @CaseDefined
SELECT rf.rf_idCase,rf.rf_idRegisterPatient
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration		          
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1				                          


CREATE TABLE #tab(rf_idCase bigint,IdStep tinyint)

INSERT #tab( rf_idCase, IdStep )
SELECT rf.rf_idCase,1
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration		          
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1				                          
---для данных вернувшихся из ФФОМС
INSERT #tab( rf_idCase, IdStep )
SELECT rf.rf_idCase,2
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration
								INNER JOIN @CaseDefined cd ON
				rf.rf_idCase=cd.rf_idCase                              
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1				                          
------------------------------------------------------------------
----проверка на дулированность случая по пациенту в РС F
IF EXISTS(SELECT 1 FROM t_File WHERE id=@idFile AND TypeFile='F')
BEGIN
	;WITH cteDouble
	AS
	(  
	SELECT ROW_NUMBER() OVER(PARTITION BY ENP,d.TypeDisp ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.ENP,d.TypeDisp,cd.IdStep
	from #tab cd inner join t_Case c on
					cd.rf_idCase=c.id	
						 INNER JOIN dbo.t_RecordCaseBack rb ON
					c.id=rb.rf_idCase
						 left JOIN dbo.t_PatientBack pb ON
					rb.id=pb.rf_idRecordCaseBack
						INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase                    
	WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ')   
	)
	insert @tError 
	SELECT distinct id,71 FROM cteDouble WHERE idRow>1
						                        
END 
go

DROP TABLE #tab
