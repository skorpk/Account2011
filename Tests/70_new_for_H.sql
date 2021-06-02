USE RegisterCases
GO
DECLARE @CaseDefined TVP_CasePatient ,		
		@idFile int	=128654


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE id=@idFile

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
									INNER JOIN dbo.t_ErrorProcessControl e ON
				rf.rf_idCase=e.rf_idCase		          
WHERE rf.rf_idFiles=@idFile AND e.rf_idFile=@idFile	AND e.ErrorNumber IN(70,71)
SELECT @@ROWCOUNT

declare @reportYear SMALLINT,
		@numReg int

------------------------------------------------------------------
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 

		SELECT @reportYear=ReportYear , @numReg=NumberRegister FROM dbo.t_RegistersCase WHERE rf_idFiles=@idFile 
		----�������� �� �������������� ������ �� �������� � �� H �� 10/10/2017 ��� ���������� � �������� ����������
		CREATE TABLE #tabAmb(rf_idCase bigint,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 TINYINT, rf_idV002 smallint, rf_idV004 int)
		--�������� ������ �� �����
		--������ �� �������������� ������������ �� 1-�� �����
		INSERT #tabAmb
		SELECT rf.rf_idCase,1,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id		          
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			                                      
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006=3 AND c.rf_idV002<>34 --AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)

		---��� ������ ����������� �� �����
		INSERT #tabAmb
		SELECT rf.rf_idCase,2,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase 
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id              
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			               
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006=3 AND c.rf_idV002<>34 AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id)				                          

		------------------------------------------------------------------
		----�������� �� �������������� ������ �� �������� � �� �� ���������� � �������� ����������
			;WITH cteDouble
			AS
			(  
				SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006,rf_idV002, rf_idV004 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP
					,DateBeg,DateEnd,DS1,NewBorn,rf_idV006,rf_idV002, rf_idV004, IDStep				
				from #tabAmb s1
			)
			SELECT distinct 1,rf_idCase,71, ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006,rf_idV002, rf_idV004,IDStep FROM cteDouble WHERE idRow>1

			--SELECT * from #tabAmb
	------------------------------------------------------70-----------------------------------	
	/*������ ����� ��  ��� �� ��������� �������*/
		SELECT distinct 2,rf_idCase,70,enp,DS1,DateBeg,DateEnd,rf_idV006,rf_idV004,@numReg,NewBorn,@codeLPU
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_AmbCaseNotExistInAccount 
					  WHERE rf_idFiles<>@idFile and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
		---2. ����� ������ ��� ��������� � ������, ��� ���.
		SELECT distinct 3,rf_idCase,70,enp,DS1,DateBeg,DateEnd,rf_idV006,rf_idV004,@numReg,NewBorn,@codeLPU
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountWithoutFin 
					  WHERE NumberRegister<>@numReg and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)

		---3. ����� ������ ��� ��������� � ������ � ������������ ��� ��� ������� ������.
		SELECT distinct 4,rf_idCase,70
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountFin 
					  WHERE NumberRegister<>@numReg AND ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
END
GO
DROP TABLE #tabAmb	