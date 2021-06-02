USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_RunProcessControl]    Script Date: 15.12.2020 14:15:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_RunProcessControl]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
	
as
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
--------------------------------------проверка на дулированность случая по пациенту в РС F от 15/08/2017--------------------------------
IF EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprT001 WHERE CodeM=@codeLPU AND pfs=1 )
BEGIN
	insert @tError
	select c.id,589
	from @CaseDefined cd inner join t_Case c on
					cd.rf_idCase=c.id
					and c.rf_idV006=4					
						inner join t_Meduslugi m on
					c.id=m.rf_idCase										 
	where NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.v001 WHERE IDRB=m.MUCode AND isTelemedicine=1
					 UNION ALL 
					 SELECT 1 FROM vw_sprMUSplitByGroup mu WHERE m.MUCode=mu.MU and mu.MUGroupCode=71 and mu.MUUnGroupCode IN (1 ,3)
					 )
	group by c.id
END
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='F')
BEGIN 
		----проверка на дулированность случая по пациенту в РС F от 15/08/2017
		CREATE TABLE #tab(rf_idCase bigint,IdStep tinyint)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
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
			SELECT ROW_NUMBER() OVER(PARTITION BY UniqueNumberPolicy,d.TypeDisp ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.UniqueNumberPolicy AS enp
				,d.TypeDisp,cd.IdStep
			from #tab cd inner join t_Case c on
							cd.rf_idCase=c.id	
								 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase
								INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase  
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
								INNER JOIN dbo.vw_CaseDefineAll pb ON
							rp.id=pb.rf_idRefCaseIteration 										                 
			WHERE d.TypeDisp ='ДВ2'
			)
			insert @tError 
			SELECT distinct id,71 FROM cteDouble WHERE idRow>1

			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY UniqueNumberPolicy/*,d.TypeDisp*/ ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.UniqueNumberPolicy AS enp
				,d.TypeDisp,cd.IdStep
			from #tab cd inner join t_Case c on
							cd.rf_idCase=c.id	
								 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase
								INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase  
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
								--INNER JOIN dbo.t_CaseDefine pb ON
								INNER JOIN dbo.vw_CaseDefineAll pb ON
							rp.id=pb.rf_idRefCaseIteration 										                 
			WHERE d.TypeDisp IN('ДВ1','ДВ4','ОПВ')   
			)
			insert @tError 
			SELECT distinct id,71 FROM cteDouble WHERE idRow>1

			
			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY UniqueNumberPolicy/*,d.TypeDisp*/ ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.UniqueNumberPolicy AS enp
				,d.TypeDisp,cd.IdStep
			from #tab cd inner join t_Case c on
							cd.rf_idCase=c.id	
								 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase
								INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase  
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
								--INNER JOIN dbo.t_CaseDefine pb ON
								INNER JOIN dbo.vw_CaseDefineAll pb ON
							rp.id=pb.rf_idRefCaseIteration 										                 
			WHERE d.TypeDisp IN('ДС1', 'ДС2','ДУ1','ДУ2')   
			)
			insert @tError 
			SELECT distinct id,71 FROM cteDouble WHERE idRow>1
			---дети до 2 лет
			DECLARE @dateStartDR DATE=CAST((@year-2) AS CHAR(4))+'0601'

			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY UniqueNumberPolicy/*,d.TypeDisp*/ ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.UniqueNumberPolicy AS enp
				,d.TypeDisp,cd.IdStep
			from #tab cd inner join t_Case c on
							cd.rf_idCase=c.id	
								 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase
								INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase  
								 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase	
								INNER JOIN dbo.t_RegisterPatient p ON
							rp.rf_idRegisterPatient=p.id		                     
								INNER JOIN dbo.vw_CaseDefineAll pb ON
							rp.id=pb.rf_idRefCaseIteration 										                 
			WHERE d.TypeDisp IN('ОН1', 'ОН2')   AND p.rf_idFiles=@idFile AND p.BirthDay<@dateStartDR
			)
			insert @tError 
			SELECT distinct id,71 FROM cteDouble WHERE idRow>1
		-----------------------------------------------------70 error--------------------------------------------------
		CREATE TABLE #tmpCasesDouble(id BIGINT, ENP VARCHAR(20), TypeDisp VARCHAR(3), ReportYear SMALLINT, NumberRegister INT, GUID_Case UNIQUEIDENTIFIER)

		IF EXISTS(SELECT * 
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase                              
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1)
		BEGIN
		--Test 70
			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
			SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ДВ',a.ReportYear, a.NumberRegister,c.GUID_Case
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ДВ1','ДВ4','ОПВ') 
			UNION ALL
            SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ДВ2',a.ReportYear, a.NumberRegister,c.GUID_Case
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp ='ДВ2'
			UNION ALL
            SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ДC',a.ReportYear, a.NumberRegister,c.GUID_Case
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ДС1', 'ДС2','ДУ1','ДУ2')   

			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
            SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ОН',a.ReportYear, a.NumberRegister,c.GUID_Case
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase
						INNER JOIN dbo.t_RegisterPatient p ON
							rp.rf_idRegisterPatient=p.id				                     
						 INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ОН1', 'ОН2') AND p.BirthDay<@dateStartDR
		END

		IF EXISTS(SELECT * 
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase                              
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1)
		BEGIN
		--Test 70
			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
			SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ДВ',a.ReportYear, a.NumberRegister,c.GUID_Case	
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ДВ1','ДВ4','ОПВ') 

			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
			SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ДВ2',a.ReportYear, a.NumberRegister,c.GUID_Case	
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp ='ДВ2'

			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
			SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ДС',a.ReportYear, a.NumberRegister,c.GUID_Case	
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
						 INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ДС1', 'ДС2','ДУ1','ДУ2') 
			
			INSERT #tmpCasesDouble (id,ENP,TypeDisp,ReportYear,NumberRegister,GUID_Case)
            SELECT c.id,pb.UniqueNumberPolicy AS ENP,'ОН',a.ReportYear, a.NumberRegister,c.GUID_Case
			from @CaseDefined cd inner join t_Case c on
							cd.rf_idCase=c.id
						 INNER JOIN dbo.t_RecordCase r ON
							c.rf_idRecordCase=r.id
						 INNER JOIN dbo.t_RegistersCase a ON
			  				r.rf_idRegistersCase=a.id			 
						 INNER JOIN dbo.t_DispInfo d ON
							c.id=d.rf_idCase
						 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase
						INNER JOIN dbo.t_RegisterPatient p ON
							rp.rf_idRegisterPatient=p.id				                     
						 INNER JOIN dbo.t_CaseDefineZP1Found pb ON
							rp.id=pb.rf_idRefCaseIteration
			WHERE d.TypeDisp IN('ОН1', 'ОН2') AND p.BirthDay<@dateStartDR

		END

		insert @tError 
		SELECT distinct id,70--,ENP,GUID_Case
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_CaseDispNotExistInAccount WHERE rf_idFiles<>@idFile and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear )--AND CodeM=@codeLPU)
		---2. Когда случай был выставлен в счетах, без РАК.
		insert @tError 
		SELECT distinct id,70--,enp,GUID_Case
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountWithoutFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear)-- AND CodeM=@codeLPU)	

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		insert @tError 
		SELECT distinct id,70--,ENP
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear)-- AND CodeM=@codeLPU)

		DROP TABLE #tmpCasesDouble
						                        
		END 

		DROP TABLE #tab				                        
END
------------------------------------проверка на полные дубли для файлов HR по стационару и дневному-----------------
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 
declare @reportYear SMALLINT,
		@numReg int
SELECT @reportYear=ReportYear , @numReg=NumberRegister FROM dbo.t_RegistersCase WHERE rf_idFiles=@idFile 
		----проверка на дулированность случая по пациенту в РС H от 10/10/2017 для стационара и дневного стационара
		CREATE TABLE #tabStac(rf_idCase bigint,IdStep TINYINT,ENP VARCHAR(16),DateBeg DATE,DateEnd DATE,NewBorn VARCHAR(9),DS1 VARCHAR(9),rf_idFile INT, NumberCase INT, rf_idV006 tinyint)
		--собираем данные по файлу
		--данные по застрахованным определенным на 1-ом этапе
		INSERT #tabStac
		SELECT DISTINCT rf.rf_idCase,1,pb.UniqueNumberPolicy,cc.DateBegin,cc.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id		          
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
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
		SELECT DISTINCT rf.rf_idCase,2,pb.UniqueNumberPolicy,cc.DateBegin,cc.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006
		FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
						rf.id=i.rf_idRefCaseIteration
										INNER JOIN @CaseDefined cd ON
						rf.rf_idCase=cd.rf_idCase 
										INNER JOIN t_Case c ON
						rf.rf_idCase=c.id              
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
											INNER JOIN dbo.t_CompletedCase cc ON
						r.id=cc.rf_idRecordCase
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
			;WITH cteDouble
			AS
			(  
			SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,/*DS1,*/NewBorn,rf_idV006 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP				
			from #tabStac s1
			)
			insert @tError 
			SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
	------------------------------------------------------70-----------------------------------
	/*Данныу берем из  той же временной таблицы*/
		insert @tError 
		SELECT distinct rf_idCase,70--,ENP,GUID_Case
		FROM #tabStac c INNER JOIN vw_CaseNotExistInAccount f ON
				f.rf_idFiles<>@idFile 
				AND f.ENP=c.ENP 
				AND f.ReportYear=@reportYear 
				AND f.CodeM=@codeLPU 
				AND f.NewBorn=c.NewBorn 
				AND f.DateBegin=c.DateBeg 
				AND f.DateEnd=c.DateEnd 
				AND f.rf_idV006=c.rf_idV006

		---2. Когда случай был выставлен в счетах, без РАК.
		insert @tError 
		SELECT distinct rf_idCase,70--,enp,GUID_Case
			FROM #tabStac c INNER JOIN  AccountOMS.dbo.vw_CaseInAccountWithoutFin f ON
				f.NumberRegister<>@numReg 
				AND f.ENP=c.ENP 
				AND f.ReportYear=@reportYear 
				AND f.CodeM=@codeLPU 
				AND f.NewBorn=c.NewBorn 
				AND f.DateBegin=c.DateBeg 
				AND f.DateEnd=c.DateEnd 
				AND f.rf_idV006=c.rf_idV006	

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		insert @tError 
		SELECT distinct rf_idCase,70
		FROM #tabStac c INNER JOIN AccountOMS.dbo.vw_CaseInAccountFin f ON
				f.NumberRegister<>@numReg 
				AND f.ENP=c.ENP 
				AND f.ReportYear=@reportYear 
				AND f.CodeM=@codeLPU 
				AND f.NewBorn=c.NewBorn 
				AND f.DateBegin=c.DateBeg 
				AND f.DateEnd=c.DateEnd 
				AND f.rf_idV006=c.rf_idV006		

		DROP TABLE #tabStac	
END
-----------------------------22.02.2018---------------------------
------------------------------------проверка на полные дубли для файлов HR по АМП-----------------
IF EXISTS(SELECT 1 FROM dbo.t_File WHERE id=@idFile AND TypeFile='H')
BEGIN 
--declare @reportYear SMALLINT,
--		@numReg int
		SELECT @reportYear=ReportYear , @numReg=NumberRegister FROM dbo.t_RegistersCase WHERE rf_idFiles=@idFile 
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
										 INNER JOIN dbo.t_RecordCaseBack rb ON
							c.id=rb.rf_idCase								
										 INNER JOIN dbo.t_RefCasePatientDefine rp ON
							c.id=rp.rf_idCase			                     
										INNER JOIN dbo.t_CaseDefine pb ON
							rp.id=pb.rf_idRefCaseIteration 							
										INNER JOIN dbo.t_Diagnosis d ON
							c.id=d.rf_idCase
							AND d.TypeDiagnosis=1			                                      
		WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1	AND c.rf_idV006=3 AND c.rf_idV002<>34

		---для данных вернувшихся из ФФОМС
		INSERT #tabAmb
		SELECT DISTINCT rf.rf_idCase,2,pb.UniqueNumberPolicy,c.DateBegin,c.DateEnd,r.NewBorn,d.DiagnosisCode, @idFile, c.idRecordCase,c.rf_idV006,c.rf_idV002, c.rf_idV004
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
		----проверка на дулированность случая по пациенту в РС по стационару и дневному стационару
			;WITH cteDouble
			AS
			(  
				SELECT ROW_NUMBER() OVER(PARTITION BY s1.ENP,DateBeg,DateEnd,DS1,NewBorn,rf_idV006,rf_idV002, rf_idV004 ORDER BY s1.IdStep,s1.NumberCase ASC) AS idRow, s1.rf_idCase,s1.NumberCase,s1.ENP				
				from #tabAmb s1
			)
			insert @tError 
			SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
	------------------------------------------------------70-----------------------------------	
	/*Данныу берем из  той же временной таблицы*/
		insert @tError 
		SELECT distinct rf_idCase,70--,ENP,GUID_Case
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_AmbCaseNotExistInAccount 
					  WHERE rf_idFiles<>@idFile and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
		---2. Когда случай был выставлен в счетах, без РАК.
		insert @tError 
		SELECT distinct rf_idCase,70--,enp,GUID_Case
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountWithoutFin 
					  WHERE NumberRegister<>@numReg and ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		insert @tError 
		SELECT distinct rf_idCase,70
		FROM #tabAmb c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_AmbCaseInAccountFin 
					  WHERE NumberRegister<>@numReg AND ENP=c.ENP AND DS1=c.DS1 AND ReportYear=@reportYear AND CodeM=@codeLPU AND NewBorn=c.NewBorn 
							AND DateBeg=c.DateBeg AND DateEnd=c.DateEnd AND rf_idV006=c.rf_idV006 AND rf_idV002=c.rf_idV002 AND rf_idV004=c.rf_idV004)
		

		DROP TABLE #tabAmb	
END
--------------------------------------------------------------------------------------------

------------------------------------------------------------------
--Проверка N: проверка плана-заказа. Всегда должна быть последней
--внес корректировки с тем что некоторые МО просят сдать данные за предыдущий отчетный год

create table #tmpPlan
(
	CodeLPU varchar(6),
	UnitCode int,
	Vm DECIMAL(11,2),
	Vdm DECIMAL(11,2),
	Spred decimal(11,2),
	[month] tinyint
)
exec usp_PlanOrders @CodeLPU,@month,@year

if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase 
	from vw_dataPlanOrder c inner join @CaseDefined cd on
				c.id=cd.rf_idCase
	where rf_idFiles=@idFile	
	order by idRecordCase asc
		
		--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred,f.Vdm+f.Vm-f.Spred from #tmpPlan f
			declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2),@totalPlan decimal(11,2)
		open cPlan
		fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		while @@FETCH_STATUS = 0
		begin					
			update @t1 set @totalPlan=TotalRest=@totalPlan-Quantity where unitCode=@unit
			
			fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		end
		close cPlan
		deallocate cPlan

		insert @tError	select distinct rf_idCase,62 from @t1 where TotalRest<0

		insert @tError	
		SELECT DISTINCT t.rf_idCase,305
		FROM @t1 t INNER JOIN @t1 t1 ON
			t.rf_idCase=t1.rf_idCase
		WHERE t.unitCode<>t1.unitCode
END

begin transaction
begin try
	--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	--select ErrorNumber,@idFile,rf_idCase 
	--from @tError
	insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	select distinct ErrorNumber,@idFile,c.id
	FROM @tError e INNER JOIN t_Case c ON 
				e.rf_idCase=c.id
						INNER JOIN t_Case cc ON
				c.rf_idRecordCase=cc.rf_idRecordCase  
end try

begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	drop table #tmpPlan
	commit transaction
	
