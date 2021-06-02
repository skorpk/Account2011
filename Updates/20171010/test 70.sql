USE RegisterCases
GO
DECLARE @CaseDefined TVP_CasePatient ,		
		@idFile int	=98374


--select @idFile=f.id from t_File f WHERE f.TypeFile='H' AND f.DateRegistration>'20170201' AND f.DateRegistration<GETDATE() AND CountSluch>1000 ORDER BY NEWID()

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

/*
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
*/

IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 
declare @reportYear SMALLINT,
		@numReg int
SELECT @reportYear=ReportYear , @numReg=NumberRegister FROM dbo.t_RegistersCase WHERE rf_idFiles=@idFile 
		----проверка на дулированность случая по пациенту в РС H от 10/10/2017 для стационара и дневного стационара
		CREATE TABLE #tabStac
		(
			rf_idCase bigint,
			IdStep TINYINT,
			ENP VARCHAR(16),
			DateBeg DATE,
			DateEnd DATE,
			NewBorn VARCHAR(9),
			DS1 VARCHAR(9),
			rf_idFile INT, 
			NumberCase INT, 
			rf_idV006 TINYINT
		)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
		INSERT #tabStac
		SELECT rf.rf_idCase,1,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
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
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006 <3

		---для данных вернувшихся из ФФОМС
		INSERT #tabStac
		SELECT rf.rf_idCase,2,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
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
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1 AND c.rf_idV006<3				                          

		------------------------------------------------------------------
		----проверка на дулированность случая по пациенту в РС по стационару и дневному стационару
			--;WITH cteDouble
			--AS
			--(  
			--SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP				
			--from #tabStac s1
			--)
			--insert @tError 
			--SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
	------------------------------------------------------70-----------------------------------
	/*Данныу берем из  той же временной таблицы*/
		--insert @tError 
		SELECT distinct rf_idCase,70--,ENP,GUID_Case
		FROM #tabStac c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_CaseNotExistInAccount 
					  WHERE rf_idFiles<>@idFile and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006)
		---2. Когда случай был выставлен в счетах, без РАК.
		--insert @tError 
		SELECT distinct rf_idCase,70--,enp,GUID_Case
		FROM #tabStac c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseInAccountWithoutFin 
					  WHERE NumberRegister<>@numReg and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006)

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		--insert @tError 
		SELECT distinct rf_idCase,70,ENP,DS1,@numReg, DateBeg ,DateEnd ,NewBorn ,NumberCase ,rf_idV006
		FROM #tabStac c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseInAccountFin 
					  WHERE NumberRegister<>@numReg AND ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006)

SELECT * 
FROM AccountOMS.dbo.vw_CaseInAccountFin 
WHERE ENP IN('3471940831000329') AND ReportYear=@reportYear AND CodeM=@codeLPU AND NumberRegister<>@numReg
END
go
DROP TABLE #tabStac	

