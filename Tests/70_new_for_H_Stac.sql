USE RegisterCases
GO
DECLARE @idFile INT=205830--205843

declare @reportYear SMALLINT,
		@numReg INT,
		@codeLPU CHAR(6)

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

SELECT @reportYear=ReportYear , @numReg=NumberRegister ,@codeLPU=f.CodeM
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles					
where f.id=@idFile
----проверка на дулированность случая по пациенту в РС H от 10/10/2017 для стационара и дневного стационара		
CREATE TABLE #tabStac(CodeM CHAR(6),rf_idRecordCase int,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 tinyint)
--собираем данные по файлу
--данные по застрахованным определенным на 1-ом этапе
INSERT #tabStac
SELECT DISTINCT c.rf_idMO,cc.rf_idRecordCase,1,pb.UniqueNumberPolicy,cc.DateBegin,cc.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration
								INNER JOIN t_Case c ON
				rf.rf_idCase=c.id		          
								INNER JOIN dbo.t_RecordCase r ON
				c.rf_idRecordCase=r.id
								INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase								 
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
					c.id=rp.rf_idCase			                     
								INNER JOIN dbo.t_CaseDefine pb ON
					rp.id=pb.rf_idRefCaseIteration 							
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1			                                      
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006 <3 --AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)

---для данных вернувшихся из ФФОМС
INSERT #tabStac
SELECT DISTINCT c.rf_idMO,cc.rf_idRecordCase,2,pb.UniqueNumberPolicy,cc.DateBegin,cc.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration										 
								INNER JOIN t_Case c ON
				rf.rf_idCase=c.id              
								INNER JOIN dbo.t_RecordCase r ON
				c.rf_idRecordCase=r.id
									INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase								 
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
					c.id=rp.rf_idCase			                     
								INNER JOIN dbo.t_CaseDefineZP1Found pb ON
					rp.id=pb.rf_idRefCaseIteration 							
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1			               
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006<3 --AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)		


DECLARE @rowCount int
		------------------------------------------------------------------
		----проверка на дулированность случая по пациенту в РС по стационару и дневному стационару
;WITH cteDouble			
AS
(  
SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,/*DS1,*/NewBorn,rf_idV006 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idRecordCase,s1.NumberCase,s1.ENP				
from #tabStac s1
)
SELECT distinct c1.id,71 
FROM cteDouble c JOIN dbo.t_Case c1 ON
			c.rf_idRecordCase=c1.rf_idRecordCase
WHERE c.idRow>1

	------------------------------------------------------70-----------------------------------
	/*Данныу берем из  той же временной таблицы*/
SELECT DISTINCT c1.id as rf_idCase,70,f.rf_idFiles
FROM #tabStac c INNER JOIN vw_CaseNotExistInAccount f ON
		f.rf_idFiles<>@idFile 
		AND f.ENP=c.ENP 
		AND f.ReportYear=@reportYear 
		AND (CASE WHEN f.rf_idV006=1 AND f.DateBegin=f.DateEnd and c.CodeM=F.CodeM THEN 1 ELSE 0 END)=1
		AND f.NewBorn=c.NewBorn 
		AND f.DateBegin=c.DateBeg 
		AND f.DateEnd=c.DateEnd 
		AND f.rf_idV006=c.rf_idV006
			JOIN dbo.t_Case c1 ON
		c.rf_idRecordCase=c1.rf_idRecordCase
WHERE f.rf_idFiles <>205851

--SELECT * FROM dbo.vw_getIdFileNumber WHERE id IN(205776,205677,205851)

---2. Когда случай был выставлен в счетах, без РАК.
SELECT distinct c1.id AS rf_idCase,70,c.DateBeg,c.DateEnd,c.rf_idV006,f.CodeM
	FROM #tabStac c INNER JOIN  AccountOMS.dbo.vw_CaseInAccountWithoutFin f ON
		f.NumberRegister<>@numReg 
		AND f.ENP=c.ENP 
		AND f.ReportYear=@reportYear 
		--AND (CASE WHEN f.rf_idV006=1 AND f.DateBegin=f.DateEnd and c.CodeM=F.CodeM THEN 1 ELSE 0 END)=1
		AND f.NewBorn=c.NewBorn 
		AND f.DateBegin=c.DateBeg 
		AND f.DateEnd=c.DateEnd 
		AND f.rf_idV006=c.rf_idV006	
			JOIN dbo.t_Case c1 ON	
		c.rf_idRecordCase=c1.rf_idRecordCase

SELECT @rowCount=@@ROWCOUNT


---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
SELECT distinct c1.id AS rf_idCase,70
FROM #tabStac c INNER JOIN AccountOMS.dbo.vw_CaseInAccountFin f ON
		f.NumberRegister<>@numReg 
		AND f.ENP=c.ENP 
		AND f.ReportYear=@reportYear 
		--AND (CASE WHEN f.rf_idV006=1 AND f.DateBegin=f.DateEnd and c.CodeM=F.CodeM THEN 1 ELSE 0 END)=1
		AND f.NewBorn=c.NewBorn 
		AND f.DateBegin=c.DateBeg 
		AND f.DateEnd=c.DateEnd 
		AND f.rf_idV006=c.rf_idV006	
			JOIN dbo.t_Case c1 ON
		c.rf_idRecordCase=c1.rf_idRecordCase	


go
DROP TABLE #tabStac	