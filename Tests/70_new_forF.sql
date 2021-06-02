USE RegisterCases
GO
DECLARE @CaseDefined TVP_CasePatient ,		
		@idFile int	=99767


select @idFile=f.id 
from t_File f INNER JOIN dbo.t_RegistersCase a ON
		f.id=a.rf_idFiles
WHERE f.TypeFile='F' AND f.DateRegistration>'20170201' AND f.DateRegistration<GETDATE() AND CodeM='571001' AND a.NumberRegister=203 AND a.ReportYear=2017 
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
IF EXISTS(SELECT 1 FROM t_File WHERE id=@idFile AND TypeFile='F')
BEGIN
----версия для тестов	
	SELECT c.id,pb.ENP,d.TypeDisp,a.ReportYear, a.NumberRegister,c.GUID_Case
	INTO #tmpCasesDouble
	from @CaseDefined cd inner join t_Case c on
					cd.rf_idCase=c.id
				 INNER JOIN dbo.t_RecordCase r ON
					c.rf_idRecordCase=r.id
				 INNER JOIN dbo.t_RegistersCase a ON
				  	r.rf_idRegistersCase=a.id
				 INNER JOIN dbo.t_RecordCaseBack rb ON
					c.id=rb.rf_idCase
				 INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase                    
				 INNER JOIN dbo.t_PatientBack pb ON
					rb.id=pb.rf_idRecordCaseBack	
				INNER JOIN dbo.t_CaseBack cb ON
					rb.id=cb.rf_idRecordCaseBack			
				
	WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ') 
	AND EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=70)--AND cb.TypePay=1
/*
рабочая версия т.к. тип оплаты еще не известен

SELECT c.id,pb.UniqueNumberPolicy,d.TypeDisp,a.ReportYear, a.NumberRegister,c.GUID_Case
INTO #tmpCasesDouble
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
WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ') 
*/

		SELECT distinct id,70--,ENP,GUID_Case
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM dbo.vw_CaseDispNotExistInAccount WHERE rf_idFiles<>@idFile and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear AND CodeM=@codeLPU)
		---2. Когда случай был выставлен в счетах, без РАК.
		SELECT distinct id,70--,enp,GUID_Case
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountWithoutFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear AND CodeM=@codeLPU)	

		---3. Когда случай был выставлен в счетах и присутствует РАК без полного снятия.
		SELECT distinct id,70,ENP
		FROM #tmpCasesDouble c 
		WHERE EXISTS (SELECT 1 FROM AccountOMS.dbo.vw_CaseDispInAccountFin WHERE NumberRegister<>c.NumberRegister and ENP=c.ENP AND TypeDisp=c.TypeDisp AND ReportYear=c.ReportYear AND CodeM=@codeLPU)

		SELECT 70,COUNT(c.ENP) AS TotalPeople,f.NumberRegister
		FROM #tmpCasesDouble c INNER JOIN AccountOMS.dbo.vw_CaseDispInAccountFin f on
				f.NumberRegister<>c.NumberRegister 
				and f.ENP=c.ENP 
				AND f.TypeDisp=c.TypeDisp 
				AND f.ReportYear=c.ReportYear 
				AND CodeM=@codeLPU
		GROUP BY f.NumberRegister
		ORDER BY TotalPeople desc
	
END 
go
DROP TABLE #tmpCasesDouble
--DROP TABLE #tab2
