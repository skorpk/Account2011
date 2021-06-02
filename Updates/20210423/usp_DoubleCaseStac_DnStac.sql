USE RegisterCases
GO
IF OBJECT_ID('usp_DoubleCaseStac_DnStac',N'P') IS NOT NULL
	DROP PROCEDURE usp_DoubleCaseStac_DnStac
GO
CREATE PROCEDURE usp_DoubleCaseStac_DnStac
				@idFile INT
AS
declare @reportYear SMALLINT,
		@numReg INT,
		@codeLPU CHAR(6)

SELECT @reportYear=ReportYear , @numReg=NumberRegister ,@codeLPU=f.CodeM
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles					
where f.id=@idFile
----�������� �� �������������� ������ �� �������� � �� H �� 10/10/2017 ��� ���������� � �������� ����������		
CREATE TABLE #tabStac(CodeM CHAR(6),rf_idRecordCase int,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 tinyint)
--�������� ������ �� �����
--������ �� �������������� ������������ �� 1-�� �����
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
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006 <3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)

---��� ������ ����������� �� �����
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
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006<3 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)		

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) SELECT GETDATE(),@idfile,COUNT(*), '10S_D' FROM #tabStac

DECLARE @rowCount int
		------------------------------------------------------------------
		----�������� �� �������������� ������ �� �������� � �� �� ���������� � �������� ����������
;WITH cteDouble			
AS
(  
SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,/*DS1,*/NewBorn,rf_idV006 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idRecordCase,s1.NumberCase,s1.ENP				
from #tabStac s1
)
insert #tError 
SELECT distinct c1.id,71 
FROM cteDouble c JOIN dbo.t_Case c1 ON
			c.rf_idRecordCase=c1.rf_idRecordCase
WHERE c.idRow>1

SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'1S_D')

	------------------------------------------------------70-----------------------------------
	/*������ ����� ��  ��� �� ��������� �������*/
insert #tError 
SELECT DISTINCT c1.id as rf_idCase,70--,ENP,GUID_Case
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
SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'2S_D')

---2. ����� ������ ��� ��������� � ������, ��� ���.
insert #tError 
SELECT distinct c1.id AS rf_idCase,70
	FROM #tabStac c INNER JOIN  AccountOMS.dbo.vw_CaseInAccountWithoutFin f ON
		f.NumberRegister<>@numReg 
		AND f.ENP=c.ENP 
		AND f.ReportYear=@reportYear 
		AND (CASE WHEN f.rf_idV006=1 AND f.DateBegin=f.DateEnd and c.CodeM=F.CodeM THEN 1 ELSE 0 END)=1
		AND f.NewBorn=c.NewBorn 
		AND f.DateBegin=c.DateBeg 
		AND f.DateEnd=c.DateEnd 
		AND f.rf_idV006=c.rf_idV006	
			JOIN dbo.t_Case c1 ON	
		c.rf_idRecordCase=c1.rf_idRecordCase
SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'3S_D')

---3. ����� ������ ��� ��������� � ������ � ������������ ��� ��� ������� ������.
insert #tError 
SELECT distinct c1.id AS rf_idCase,70
FROM #tabStac c INNER JOIN AccountOMS.dbo.vw_CaseInAccountFin f ON
		f.NumberRegister<>@numReg 
		AND f.ENP=c.ENP 
		AND f.ReportYear=@reportYear 
		AND (CASE WHEN f.rf_idV006=1 AND f.DateBegin=f.DateEnd and c.CodeM=F.CodeM THEN 1 ELSE 0 END)=1
		AND f.NewBorn=c.NewBorn 
		AND f.DateBegin=c.DateBeg 
		AND f.DateEnd=c.DateEnd 
		AND f.rf_idV006=c.rf_idV006	
			JOIN dbo.t_Case c1 ON
		c.rf_idRecordCase=c1.rf_idRecordCase	
SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'4S_D')

---���� ����� ������, ������ ������ � ������� � ��������. ���� �� � ����������� �� ����������� ����� ������ ��� ������� ���� ������
INSERT t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
select distinct ErrorNumber,@idFile,c.id
FROM #tError e INNER JOIN t_Case c ON 
			e.rf_idCase=c.id
					INNER JOIN t_Case cc ON
			c.rf_idRecordCase=cc.rf_idRecordCase  
SELECT @rowCount=@@ROWCOUNT

INSERT dbo.t_LogDouble(DateRegistration,rf_idFile,TotalRow,TypeQuery) VALUES( GETDATE(),@idFile,@rowCount,'S_D_E')

DROP TABLE #tabStac	
GO
GRANT EXECUTE ON usp_DoubleCaseStac_DnStac TO db_RegisterCase