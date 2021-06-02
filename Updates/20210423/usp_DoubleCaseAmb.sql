USE RegisterCases
GO
IF OBJECT_ID('usp_DoubleCaseAmb',N'P') IS NOT NULL
	DROP PROCEDURE usp_DoubleCaseAmb
GO
CREATE PROCEDURE usp_DoubleCaseAmb
				@idFile INT
AS
declare @reportYear SMALLINT,
		@numReg INT,
		@codeLPU CHAR(6)

SELECT @reportYear=ReportYear , @numReg=NumberRegister ,@codeLPU=f.CodeM
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles					
where f.id=@idFile

----проверка на дулированность случая по пациенту в РС H от 10/10/2017 для стационара и дневного стационара
CREATE TABLE #tabAmb(rf_idCase bigint,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 TINYINT, rf_idV002 smallint, rf_idV004 int)
--собираем данные по файлу
--данные по застрахованным определенным на 1-ом этапе
INSERT #tabAmb
SELECT DISTINCT rf.rf_idCase,1,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration
								INNER JOIN t_Case c ON
				rf.rf_idCase=c.id		          
								INNER JOIN dbo.t_RecordCase r ON
				c.rf_idRecordCase=r.id								 		
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
					c.id=rp.rf_idCase			                     
								INNER JOIN dbo.t_CaseDefine pb ON
					rp.id=pb.rf_idRefCaseIteration 							
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1			                                      
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006=3 AND c.rf_idV002 NOT IN(6,15,34,78,106,123) AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)		      

---для данных вернувшихся из ФФОМС
INSERT #tabAmb
SELECT DISTINCT rf.rf_idCase,2,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration										
								INNER JOIN t_Case c ON
				rf.rf_idCase=c.id              
								INNER JOIN dbo.t_RecordCase r ON
				c.rf_idRecordCase=r.id								 
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
					c.id=rp.rf_idCase			                     
								INNER JOIN dbo.t_CaseDefineZP1Found pb ON
					rp.id=pb.rf_idRefCaseIteration 							
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1			               
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006=3 AND c.rf_idV002 NOT IN (6,15,34,78,106,123) AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)				             

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) SELECT GETDATE(),@idfile,COUNT(*), '30Amb' FROM #tabAmb           

DECLARE @rowCount int
------------------------------------------------------------------
----проверка на дулированность случая по пациенту в РС по стационару и дневному стационару
;WITH cteDouble
AS
(  
	SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006,rf_idV002, rf_idV004 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP			
	from #tabAmb s1
)
insert #tError SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1

SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'1Amb')
--------------------------------------------------70-----------------------------------	
insert #tError 
SELECT distinct rf_idCase,70--,ENP,GUID_Case
FROM #tabAmb c 
WHERE EXISTS (SELECT 1 FROM dbo.vw_AmbCaseNotExistInAccount 
			  WHERE rf_idFiles<>@idFile and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
					AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'2Amb')

---2. Когда случай был выставлен в счетах, без РАК.
insert #tError 
SELECT distinct rf_idCase,70--,enp,GUID_Case
FROM #tabAmb c 
WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountWithoutFin 
			  WHERE NumberRegister<>@numReg and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
					AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
SELECT @rowCount=@@ROWCOUNT
INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'3Amb')
---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
insert #tError 
SELECT distinct rf_idCase,70
FROM #tabAmb c 
WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountFin 
			  WHERE NumberRegister<>@numReg AND ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
					AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
SELECT @rowCount=@@ROWCOUNT
INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'4Amb')

---если нашли ошибку, кладем запись в таблицу с ошибками. счто бы в последующем не учитывались такие записи для расчета план заказа
INSERT t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
select distinct ErrorNumber,@idFile,c.id
FROM #tError e INNER JOIN t_Case c ON 
			e.rf_idCase=c.id
					INNER JOIN t_Case cc ON
			c.rf_idRecordCase=cc.rf_idRecordCase  
SELECT @rowCount=@@ROWCOUNT
INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'0A_E')

DROP TABLE #tabAmb	
GO
GRANT EXECUTE ON usp_DoubleCaseAmb TO db_RegisterCase