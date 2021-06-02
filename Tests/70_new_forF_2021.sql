USE RegisterCases
GO
DECLARE @CaseDefined TVP_CasePatient ,		
		@idFile int	=99767


select @idFile=f.id 
from t_File f INNER JOIN dbo.t_RegistersCase a ON
		f.id=a.rf_idFiles
WHERE f.TypeFile='F' AND f.DateRegistration>'20210101' AND f.DateRegistration<GETDATE() AND CodeM='491001' AND a.NumberRegister=2 AND a.ReportYear=2021
	   --AND f.CountSluch>1000 ORDER BY NEWID()

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
WHERE rf.rf_idFiles=@idFile 				                          

------------------------------------------------------------------
----проверка на дулированность случая по пациенту в РС F
DECLARE @dateStartDR DATE=CAST((@year-2) AS CHAR(4))+'0601'
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
		----------------------------------------------
--SELECT * FROM #tmpCasesDouble

SELECT rf_idFiles,d.enp,d.TypeDisp,d.ReportYear
INTO #tDisp 
FROM vw_CaseDispNotExistInAccount d INNER JOIN #tmpCasesDouble t ON
		d.ENP=t.ENP
WHERE d.ReportYear>2020

PRINT @@ROWCOUNT
-------------------------------------------------
SELECT distinct id,70
FROM #tmpCasesDouble c 
WHERE EXISTS (SELECT 1 FROM #tDisp WHERE rf_idFiles<>@idFile and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear )

---2. Когда случай был выставлен в счетах, без РАК.
SELECT distinct id,70--,enp,GUID_Case
FROM #tmpCasesDouble c 
WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountWithoutFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear)-- AND CodeM=@codeLPU)	

---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
SELECT distinct id,70--,ENP
FROM #tmpCasesDouble c 
WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear)-- AND CodeM=@codeLPU)

go
DROP TABLE #tmpCasesDouble
go			                        
DROP TABLE #tDisp